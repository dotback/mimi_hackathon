import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../logic/services/api_service.dart';
import '../logic/services/api_cognitive_test_service.dart';
import 'cognitive_test_screen.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialTestResult;

  const HomeScreen({
    super.key, 
    this.initialTestResult,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<User> _userProfile;
  final ApiService _apiService = ApiService();
  final ApiCognitiveTestService _cognitiveTestService = ApiCognitiveTestService();
  Map<String, dynamic>? _localCognitiveTestResult;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchLocalCognitiveTestResult();

    // 初期テスト結果がある場合は保存
    if (widget.initialTestResult != null) {
      _saveInitialTestResult();
    }
  }

  void _fetchUserProfile() {
    setState(() {
      _userProfile = _apiService.fetchUserProfile('dummy_user_id');
    });
  }

  void _fetchLocalCognitiveTestResult() async {
    final result = await _cognitiveTestService.getLocalCognitiveTestResult();
    setState(() {
      _localCognitiveTestResult = result;
    });

    // ローカルストレージからの結果があれば、ユーザープロファイルを更新
    if (result != null) {
      final user = await _userProfile;
      final updatedUser = user.copyWith(
        cognitiveFunctionScore: result['score'],
        cognitiveFunctionComment: result['comment'],
      );

      setState(() {
        _userProfile = Future.value(updatedUser);
      });
    }
  }

  void _saveInitialTestResult() async {
    try {
      // ユーザープロファイルを取得
      User user = await _userProfile;

      // 認知機能テスト結果を保存
      User updatedUser = await _cognitiveTestService.saveCognitiveTestResult(
        user: user,
        cognitiveFunctionScore: widget.initialTestResult!['score'],
        cognitiveFunctionComment: widget.initialTestResult!['comment'],
      );

      // 画面を更新
      setState(() {
        _userProfile = Future.value(updatedUser);
        _localCognitiveTestResult = {
          'score': widget.initialTestResult!['score'],
          'comment': widget.initialTestResult!['comment'] ?? '',
          'date': DateTime.now().toIso8601String(),
        };
      });

      // スナックバーで結果を表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('認知機能テスト結果: スコア ${widget.initialTestResult!['score']} / 10'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // エラーハンドリング
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('テスト結果の保存に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ログアウト処理
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      // サイドバーを追加
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'メニュー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('ホーム'),
              onTap: () {
                // 現在のページなので、ドロワーを閉じるだけ
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('マイプロフィール'),
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('テスト結果'),
              onTap: () {
                // TODO: テスト結果画面を実装後に修正
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('テスト結果画面は準備中です')),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('ログアウト'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: FutureBuilder<User>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            User user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('こんにちは、${user.name}さん'),
                  Text('年齢: ${user.age}歳'),
                  Text('運動習慣: ${user.exerciseHabit}'),
                  
                  // ローカルストレージの認知機能テスト結果を表示
                  if (_localCognitiveTestResult != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      '最新の認知機能テスト結果',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('スコア: ${_localCognitiveTestResult!['score']} / 10'),
                    Text(
                      _localCognitiveTestResult!['comment'],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _getCommentColor(_localCognitiveTestResult!['score'])),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CognitiveTestScreen(),
                        ),
                      );

                      // テスト結果が返ってきた場合
                      if (result != null && result is Map<String, dynamic>) {
                        try {
                          // 認知機能テスト結果を保存
                          User updatedUser = await _cognitiveTestService.saveCognitiveTestResult(
                            user: user,
                            cognitiveFunctionScore: result['score'],
                            cognitiveFunctionComment: result['comment'],
                          );

                          // 画面を更新
                          setState(() {
                            _userProfile = Future.value(updatedUser);
                            _localCognitiveTestResult = {
                              'score': result['score'],
                              'comment': result['comment'] ?? '',
                              'date': DateTime.now().toIso8601String(),
                            };
                          });

                          // スナックバーで結果を表示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('認知機能テスト結果: スコア ${result['score']} / 10'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } catch (e) {
                          // エラーハンドリング
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('テスト結果の保存に失敗しました: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('認知機能テストを受ける'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('データがありません'));
        },
      ),
    );
  }

  // スコアに応じたコメントの色を返す
  Color _getCommentColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
} 
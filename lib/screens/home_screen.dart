import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/user.dart';
import '../logic/services/api_service.dart';
import '../logic/services/api_cognitive_test_service.dart';
import 'package:get/get.dart';

import '../logic/services/shared_preferences_service.dart';
import 'cognitive_test_screen.dart';
import 'daily_problem_screen.dart';
import 'user_profile_screen.dart';
import '../services/auth_service.dart';

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
  // ユーザーデータ、APIサービス、テスト結果などを管理する変数を定義
  late final ApiService _apiService;
  late final ApiCognitiveTestService _cognitiveTestService;
  late final SharedPreferencesService _sharedPreferencesService;
  late Future<User> _user;
  Map<String, dynamic>? _cognitiveTestResult;

  @override
  void initState() {
    super.initState();
    // サービスの初期化
    _apiService = ApiService();
    _cognitiveTestService = ApiCognitiveTestService();
    _sharedPreferencesService = SharedPreferencesService();
    // ユーザープロファイルと認知機能テスト結果の取得
    _initializeData();
  }

  /// ユーザープロファイルと認知機能テスト結果を初期化する
  Future<void> _initializeData() async {
    _fetchUserProfile();
    await _fetchCognitiveTestResult();

    // 初期テスト結果がある場合は保存する
    if (widget.initialTestResult != null) {
      await _saveInitialTestResult();
    }
  }

  /// ユーザープロファイルを取得する
  void _fetchUserProfile() {
    setState(() {
      _user = _apiService.fetchUserProfile('dummy_user_id');
    });
  }

  /// 認知機能テスト結果をローカルストレージから取得する
  Future<void> _fetchCognitiveTestResult() async {
    final result = await _cognitiveTestService.getLocalCognitiveTestResult();
    setState(() {
      _cognitiveTestResult = result;
    });
  }

  /// 初期テスト結果を保存する
  Future<void> _saveInitialTestResult() async {
    try {
      User user = await _user;

      User updatedUser = await _cognitiveTestService.saveCognitiveTestResult(
        user: user,
        cognitiveFunctionScore: widget.initialTestResult!['score'],
        cognitiveFunctionComment: widget.initialTestResult!['comment'],
      );

      setState(() {
        _user = Future.value(updatedUser);
      });

      final localResult =
          await _cognitiveTestService.getLocalCognitiveTestResult();
      setState(() {
        _cognitiveTestResult = {
          'score': widget.initialTestResult!['score'],
          'comment': widget.initialTestResult!['comment'],
          'date': localResult?['date'] ?? DateTime.now().toIso8601String(),
        };
      });

      _showSuccessSnackBar(
          '認知機能テスト結果: スコア ${widget.initialTestResult!['score']} / 10');
    } catch (e) {
      _showErrorSnackBar('テスト結果の保存に失敗しました: $e');
    }
  }

  /// 成功メッセージのスナックバーを表示する
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// エラーメッセージのスナックバーを表示する
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// ログアウト処理を行う
  Future<void> _logout() async {
    final AuthService authService = Get.find<AuthService>();
    await authService.signOut();
    await _sharedPreferencesService.clearLoginStatus();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  /// 認知機能テスト結果の色を取得する
  Color _getTestResultColor(int? score) {
    if (score == null) return Colors.grey;
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  /// ドロワーメニューのアイテムを生成する
  List<Widget> _buildDrawerItems(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('ホーム'),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('マイプロフィール'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfileScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.list),
        title: const Text('テスト結果'),
        onTap: () {
          Navigator.pop(context);
          // TODO: テスト結果画面への遷移を実装
          _showSuccessSnackBar('テスト結果画面は準備中です');
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('ログアウト'),
        onTap: () async {
          await _logout();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
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
            ..._buildDrawerItems(context),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<User>(
          future: _user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('エラー: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('データがありません'));
            }

            User user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 24),
                  _buildCognitiveTestResult(context),
                  const SizedBox(height: 24),
                  _buildToDoList(context),
                  const SizedBox(height: 24),
                  _buildDailyProblemButton(context),
                  const SizedBox(height: 24),
                  Center(
                    child: _buildCognitiveTestButton(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ヘッダー部分を構築する
  Widget _buildHeader(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'こんにちは、${user.name}さん',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('yyyy年M月d日 (E)', 'ja_JP').format(DateTime.now()),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  /// 認知機能テスト結果を表示するウィジェットを構築する
  Widget _buildCognitiveTestResult(BuildContext context) {
    if (_cognitiveTestResult == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最新の認知機能テスト結果',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'スコア: ${_cognitiveTestResult!['score']} / 10',
          style: TextStyle(
            fontSize: 16,
            color: _getTestResultColor(_cognitiveTestResult!['score']),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _cognitiveTestResult!['comment'],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// 今日のTo Doリストを表示するウィジェットを構築する
  Widget _buildToDoList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日のTo Doリスト',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: ToDo追加処理の実装
              },
              child: const Text('追加'),
            ),
          ],
        ),
        // TODO: ToDoリストの実装
        const Text('現在のToDoはありません'),
      ],
    );
  }

  /// 今日の問題ボタンを構築する
  Widget _buildDailyProblemButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日の問題',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DailyProblemScreen()),
            );
          },
          child: const Text('今日の問題を解く'),
        ),
      ],
    );
  }

  /// 認知機能テストボタンを構築する
  Widget _buildCognitiveTestButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 48),
      ),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CognitiveTestScreen()),
        );

        // テスト結果が返ってきたら、ローカルのテスト結果とユーザープロファイルを更新
        if (result != null) {
          await _fetchCognitiveTestResult();
          _fetchUserProfile();
        }
      },
      child: const Text('認知機能テストを受ける'),
    );
  }
}

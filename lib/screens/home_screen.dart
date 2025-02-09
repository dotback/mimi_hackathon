import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/models/user.dart' as local_user;
import '../logic/services/api_service.dart';
import '../logic/services/api_cognitive_test_service.dart';
import 'package:get/get.dart';

import '../logic/services/shared_preferences_service.dart';
import 'cognitive_test_screen.dart';
import 'daily_problem_screen.dart';
import 'user_profile_screen.dart';
import '../services/auth_service.dart';
import '../login/login_screen.dart';
import '../services/gemini_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ユーザーデータ、APIサービス、テスト結果などを管理する変数を定義
  late final ApiService _apiService;
  late final ApiCognitiveTestService _cognitiveTestService;
  late final SharedPreferencesService _sharedPreferencesService;
  late local_user.User _user;
  Map<String, dynamic>? _cognitiveTestResult;
  String _userEmail = 'ゲストユーザー';
  late final GeminiService _geminiService;
  bool _isGeneratingTest = false;
  List<dynamic> _todoList = [];

  /// モックデータ: ToDoリスト
  // ignore: unused_field
  final List<Map<String, dynamic>> _mockTodoList = [
    {
      'title': '朝のストレッチ',
      'completed': false,
      'icon': Icons.fitness_center,
    },
    {
      'title': '脳トレアプリ',
      'completed': true,
      'icon': Icons.psychology,
    },
    {
      'title': '散歩',
      'completed': false,
      'icon': Icons.directions_walk,
    },
  ];

  /// モックデータ: 最近の活動
  // ignore: unused_field
  final List<Map<String, dynamic>> _mockRecentActivities = [
    {
      'title': '認知機能テスト',
      'date': '2023-06-15',
      'score': 8,
      'icon': Icons.assessment,
    },
    {
      'title': '言語学習',
      'date': '2023-06-14',
      'score': 7,
      'icon': Icons.language,
    },
  ];

  @override
  void initState() {
    super.initState();
    // サービスの初期化
    _apiService = ApiService();
    _cognitiveTestService = ApiCognitiveTestService();
    _sharedPreferencesService = SharedPreferencesService();
    _geminiService = GeminiService();

    // デフォルトのユーザーを初期化
    _user = local_user.User.createDefaultUser();

    // メールアドレスの読み込みを最初に実行
    _loadUserEmail().then((_) {
      _initializeData();

      // ToDoリストをローカルストレージから読み込む
      _loadTodoListFromLocalStorage();

      // 初期テスト結果がある場合は保存する
      if (Get.arguments != null && Get.arguments['initialTestResult'] != null) {
        _saveInitialTestResult(Get.arguments['initialTestResult']);
      }
    });
  }

  @override
  void dispose() {
    // サービスのクリーンアップ
    // _apiService.dispose();
    // _cognitiveTestService.dispose();
    // _sharedPreferencesService.dispose();
    super.dispose();
  }

  /// ユーザープロファイルと認知機能テスト結果を初期化する
  Future<void> _initializeData() async {
    try {
      // ユーザーIDを取得（ログイン中のユーザーから）
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? 'dummy_user_id';

      // ユーザープロファイルを取得
      try {
        final fetchedUser = await _apiService.fetchUserProfile();

        setState(() {
          _user = fetchedUser;
        });
      } catch (fetchError) {
        // デフォルトユーザーを設定
        setState(() {
          _user = local_user.User(
            username: 'ゲストユーザー',
            gender: 'unknown',
            age: 0,
            exerciseHabit: 'none',
            sleepHours: 0.0,
            email: _userEmail,
            birthDate: null,
          );
        });
      }

      // 認知機能テスト結果を取得
      await _fetchCognitiveTestResult();
    } catch (e) {
      // エラー時のフォールバック
      setState(() {
        _user = local_user.User(
          username: 'ゲストユーザー',
          gender: 'unknown',
          age: 0,
          exerciseHabit: 'none',
          sleepHours: 0.0,
          email: _userEmail,
          birthDate: null,
        );
      });
    }
  }

  /// 認知機能テスト結果をローカルストレージから取得する
  Future<void> _fetchCognitiveTestResult() async {
    final result = await _cognitiveTestService.getLocalCognitiveTestResult();
    setState(() {
      _cognitiveTestResult = result;
    });
  }

  /// 初期テスト結果を保存する
  Future<void> _saveInitialTestResult(
      Map<String, dynamic> initialTestResult) async {
    try {
      local_user.User user = await _user;

      local_user.User updatedUser =
          await _cognitiveTestService.saveCognitiveTestResult(
        user: user,
        cognitiveFunctionScore: initialTestResult['score'],
        cognitiveFunctionComment: initialTestResult['comment'],
      );

      setState(() {
        _user = updatedUser;
      });

      final localResult =
          await _cognitiveTestService.getLocalCognitiveTestResult();
      setState(() {
        _cognitiveTestResult = {
          'score': initialTestResult['score'],
          'comment': initialTestResult['comment'],
          'date': localResult?['date'] ?? DateTime.now().toIso8601String(),
        };
      });

      _showSuccessSnackBar('認知機能テスト結果: スコア ${initialTestResult['score']}');
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

    // メールアドレスをクリア
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    setState(() {
      _userEmail = 'ゲストユーザー';
    });

    if (!mounted) return;

    // ログイン画面に遷移する前に、画面を更新する
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: const RouteSettings(
          arguments: null,
        ),
      ),
    );
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
          Get.back();
          Get.to(() => const UserProfileScreen());
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

  /// ToDoリストアイテムのウィジェットを構築
  Widget _buildTodoListItem(Map<String, dynamic> todo) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          todo['icon'],
          color: todo['completed'] ? Colors.green : Colors.grey,
        ),
        title: Text(
          todo['title'],
          style: TextStyle(
            decoration: todo['completed']
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo['completed'] ? Colors.grey : Colors.black,
          ),
        ),
        trailing: Checkbox(
          value: todo['completed'],
          onChanged: (bool? value) {
            // ToDoの完了状態を更新
            setState(() {
              // 元のリストを更新
              final index = _todoList
                  .indexWhere((item) => item['title'] == todo['title']);
              if (index != -1) {
                _todoList[index]['completed'] = value ?? false;
              }
            });
          },
        ),
      ),
    );
  }

  /// 最近の活動ウィジェットを構築
  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近の活動',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _mockRecentActivities.length,
          (index) {
            final activity = _mockRecentActivities[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  activity['icon'],
                  color: Colors.blue.shade700,
                ),
                title: Text(
                  activity['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${activity['date']} - スコア: ${activity['score']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// ヘッダー部分を構築する（デザイン更新）
  Widget _buildHeader(BuildContext context, local_user.User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'こんにちは、$_userEmailさん',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy年M月d日 (E)', 'ja_JP').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
              // モックのプロフィール画像
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/images/user_icon.png')
                    as ImageProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ToDoリストを表示するウィジェットを構築（デザイン更新）
  Widget _buildToDoList(BuildContext context) {
    // _todoListが空の場合はToDoリストを表示しない
    if (_todoList.isEmpty) {
      return const SizedBox.shrink();
    }

    final todoListToShow = _todoList
        .map((todo) => {
              'title': todo['title'] ?? '',
              'completed': todo['completed'] ?? false,
              'icon': _getIconForTodo(todo['title'] ?? ''),
            })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日のTo Doリスト',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: ToDo追加モーダルの実装
                _showAddTodoDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ToDoリストを表示
        ...todoListToShow.map((todo) => _buildTodoListItem(todo)).toList(),
      ],
    );
  }

  // ToDoのタイトルに基づいてアイコンを取得するヘルパーメソッド
  IconData _getIconForTodo(String title) {
    switch (title.toLowerCase()) {
      case '朝の体操':
        return Icons.fitness_center;
      case '脳トレアプリ':
        return Icons.psychology;
      case '散歩':
        return Icons.directions_walk;
      default:
        return Icons.task; // デフォルトのアイコン
    }
  }

  /// ToDoを追加するダイアログ
  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいToDoを追加'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'ToDoを入力',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: ToDoの追加処理
                Navigator.pop(context);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  /// 認知機能テスト結果を表示するウィジェットを構築する
  Widget _buildCognitiveTestResult(BuildContext context) {
    return FutureBuilder<local_user.User>(
      future: Future.value(_user),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || _cognitiveTestResult == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '認知機能テスト結果',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_isGeneratingTest)
                      const SpinKitWave(
                        color: Colors.blue,
                        size: 30.0,
                      )
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AIパーソナライズ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _generatePersonalizedTest,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'スコア: ${_cognitiveTestResult?['score'] ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'コメント: ${_cognitiveTestResult?['comment'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 今日の問題ボタンを構築する
  Widget _buildDailyProblemButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // ナビゲーション時に遷移アニメーションを追加
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DailyProblemScreen(),
                settings: RouteSettings(
                  arguments: null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日の問題',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '認知機能を鍛える毎日の課題に挑戦しましょう',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DailyProblemScreen(),
                          settings: RouteSettings(
                            arguments: null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 認知機能テストボタンを構築する
  Widget _buildCognitiveTestButton(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // ナビゲーション時に遷移アニメーションを追加
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CognitiveTestScreen(),
                settings: RouteSettings(
                  arguments: null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '認知機能テスト',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.purple.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '現在の認知能力を評価しましょう',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.purple.shade800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.assessment_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CognitiveTestScreen(),
                          settings: RouteSettings(
                            arguments: null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ユーザーのメールアドレスをローカルストレージから読み込む
  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');

      // ログイン中のユーザーのメールアドレスを取得
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;

      setState(() {
        // 優先順位: 1. ログイン中のユーザーのメールアドレス 2. SharedPreferencesに保存されたメールアドレス 3. ゲストユーザー
        _userEmail = userEmail ?? storedEmail ?? 'ゲストユーザー';
      });
    } catch (e) {
      setState(() {
        _userEmail = 'ゲストユーザー';
      });
    }
  }

  /// ログイン時にメールアドレスを保存するメソッドを追加
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    setState(() {
      _userEmail = email;
    });
  }

  /// Geminiでテストを生成するメソッドを追加
  Future<void> _generatePersonalizedTest() async {
    if (_cognitiveTestResult == null) {
      _showErrorSnackBar('先に認知機能テストを受けてください');
      return;
    }

    // オーバーレイを表示
    final overlayEntry = _showLoadingOverlay(context);

    try {
      // ユーザーデータを取得
      local_user.User user = await _user;

      // 問題とToDoリストを同時に生成
      final generatedTest = await _geminiService.generatePersonalizedTest(
          _cognitiveTestResult!, user);

      // オーバーレイを削除
      overlayEntry.remove();

      // ローカルストレージから明示的にToDoリストを取得
      final todoList = await _geminiService.getLocalTodoList();

      // ToDoリストを更新（completedフィールドを追加）
      final updatedTodoList = todoList
          .map((todo) => {
                ...todo,
                'completed': false, // 初期状態は未完了
                'icon': _getIconForTodo(todo['title'] ?? ''),
              })
          .toList();

      // ToDoリストを更新
      setState(() {
        _todoList = updatedTodoList;
      });

      // 成功メッセージを表示
      _showSuccessDialog(context, 'AIがパーソナライズされた問題とToDoリストを生成しました！');
    } catch (e) {
      // オーバーレイを削除
      overlayEntry.remove();

      _showErrorSnackBar('テスト生成中にエラーが発生しました: $e');
    }
  }

  /// ローディングオーバーレイを表示
  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitCubeGrid(
                  color: Colors.white,
                  size: 80.0,
                ),
                SizedBox(height: 20),
                Text(
                  'Gemini AIがパーソナライズされた問題とToDoリストを生成しています...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  /// 成功ダイアログを表示
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('問題生成完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // ToDoリストをローカルストレージから読み込むメソッド
  Future<void> _loadTodoListFromLocalStorage() async {
    try {
      final todoList = await _geminiService.getLocalTodoList();

      // ToDoリストを更新（completedフィールドを追加）
      final updatedTodoList = todoList
          .map((todo) => {
                ...todo,
                'completed': todo['completed'] ?? false,
                'icon': _getIconForTodo(todo['title'] ?? ''),
              })
          .toList();

      setState(() {
        _todoList = updatedTodoList;
      });
    } catch (e) {
      // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('ユーザー名'),
              accountEmail: Text(_userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/images/user_icon.png')
                    as ImageProvider,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            ..._buildDrawerItems(context),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<local_user.User>(
          future: Future.value(_user),
          builder: (context, snapshot) {
            // 読み込み中の状態
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // エラーまたはデータがない場合のフォールバック
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ユーザー情報を読み込めませんでした'),
                    ElevatedButton(
                      onPressed: () {
                        // データの再読み込み
                        _initializeData();
                      },
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              );
            }

            // データが正常に読み込まれた場合
            local_user.User user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 24),
                  _buildCognitiveTestResult(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildDailyProblemButton(context),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _buildCognitiveTestButton(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildToDoList(context),
                  const SizedBox(height: 24),
                  _buildRecentActivities(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

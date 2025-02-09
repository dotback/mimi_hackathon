import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: LoginDialogContent(key: UniqueKey()),
    );
  }
}

class LoginDialogContent extends StatefulWidget {
  const LoginDialogContent({Key? key}) : super(key: key);

  @override
  _LoginDialogContentState createState() => _LoginDialogContentState();
}

class _LoginDialogContentState extends State<LoginDialogContent>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _resetState();
    }
  }

  void _resetState() {
    setState(() {
      _isLogin = true;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _handleLogin() async {
    final authService = Get.find<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('エラー', 'メールアドレスとパスワードを入力してください');
      return;
    }

    try {
      print('ログイン試行: $email'); // デバッグログ
      final user = await authService.signIn(email, password);
      if (user != null) {
        print('ログイン成功: ${user.uid}'); // デバッグログ
        print('ユーザーメール: ${user.email}'); // デバッグログ

        // メールアドレスを明示的に保存
        await authService.saveUserEmail(email);

        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar('エラー', 'ログインに失敗しました');
      }
    } catch (e) {
      print('ログイン中のエラー: $e'); // デバッグログ
      Get.snackbar('エラー', 'ログイン中にエラーが発生しました: $e');
    }
  }

  void _handleSignUp() async {
    final authService = Get.find<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('エラー', 'メールアドレスとパスワードを入力してください');
      return;
    }

    try {
      print('新規登録試行: $email'); // デバッグログ
      final user = await authService.signUp(email, password);
      if (user != null) {
        print('新規登録成功: ${user.uid}'); // デバッグログ
        print('ユーザーメール: ${user.email}'); // デバッグログ
        await authService.saveUserEmail(email);
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar('エラー', '新規登録に失敗しました');
      }
    } catch (e) {
      print('新規登録中のエラー: $e'); // デバッグログ
      Get.snackbar('エラー', '新規登録中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child:
                  Icon(Icons.account_circle, size: 60, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Text(
              'みんなの認知機能アプリへようこそ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLogin ? Colors.blue : Colors.grey[300],
                    foregroundColor: _isLogin ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('ログイン'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isLogin ? Colors.blue : Colors.grey[300],
                    foregroundColor: !_isLogin ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('新規登録'),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isLogin) {
                  _handleLogin();
                } else {
                  _handleSignUp();
                }
              },
              child: Text('メールアドレスで${_isLogin ? 'ログイン' : '新規登録'}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('パスワードをお忘れの方はこちら'),
            ),
            SizedBox(height: 10),
            Text('または'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.g_mobiledata, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Googleでログイン', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apple, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Appleでログイン', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

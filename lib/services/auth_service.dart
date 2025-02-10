import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ユーザー登録
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // 具体的なエラーメッセージを返す
      switch (e.code) {
        case 'weak-password':
          Get.snackbar('エラー', 'パスワードが弱すぎます');
          break;
        case 'email-already-in-use':
          Get.snackbar('エラー', 'このメールアドレスは既に使用されています');
          break;
        default:
          Get.snackbar('エラー', '登録に失敗しました: ${e.message}');
      }
      return null;
    }
  }

  // ログイン後にメールアドレスを保存するメソッド
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // ログイン
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // ログイン成功時にメールアドレスを保存
      await saveUserEmail(email);

      return result.user;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // エラーハンドリング
    }
  }

  // 現在のユーザー
  User? get currentUser => _auth.currentUser;
}

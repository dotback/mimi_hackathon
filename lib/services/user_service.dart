import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  final Rx<User?> _user = Rx<User?>(null);

  User? get user => _user.value;
  bool get isLoggedIn => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    // ユーザーの状態を監視
    _user.bindStream(FirebaseAuth.instance.authStateChanges());
  }
}

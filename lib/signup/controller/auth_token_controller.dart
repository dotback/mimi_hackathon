import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AuthTokenController extends GetxController {
  final RxString _token = ''.obs;
  Timer? _refreshTimer;
  static const refreshInterval = Duration(minutes: 45); // トークンの有効期限は1時間

  @override
  void onInit() {
    super.onInit();
    _setupTokenRefresh();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupTokenRefresh(); // ユーザーがサインインしたらリフレッシュを開始
      } else {
        _stopTokenRefresh(); // サインアウト時にリフレッシュを停止
        setToken('');
      }
    });
  }

  void _setupTokenRefresh() {
    _stopTokenRefresh();
    refreshToken();
    _refreshTimer = Timer.periodic(refreshInterval, (_) {
      refreshToken();
    });
  }

  Future<void> refreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken(true);
        if (token != null) {
          setToken(token);
        }
      } catch (e) {
        print('トークンのリフレッシュに失敗: $e');
      }
    }
  }

  void _stopTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void onClose() {
    _stopTokenRefresh();
    super.onClose();
  }

  String get token => _token.value;

  void setToken(String value) {
    _token.value = value;
  }
}

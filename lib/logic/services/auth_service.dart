import 'dart:async';

/// @Deprecated('Firebase AuthServiceに移行しました')
/// 古い認証サービスは使用しないでください
class AuthService {
  @Deprecated('Firebase AuthServiceに移行')
  Future<bool> login(String email, String password) async {
    throw UnimplementedError('新しいAuthServiceを使用してください');
  }

  @Deprecated('Firebase AuthServiceに移行')
  Future<void> logout() async {
    throw UnimplementedError('新しいAuthServiceを使用してください');
  }

  @Deprecated('Firebase AuthServiceに移行')
  Future<bool> resetPassword(String email) async {
    throw UnimplementedError('新しいAuthServiceを使用してください');
  }
}

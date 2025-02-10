class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'パスワードを入力してください';
    }
    if (password.length < 6) {
      return 'パスワードは6文字以上である必要があります';
    }
    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'ユーザー名を入力してください';
    }

    if (username.length < 4) {
      return 'ユーザー名は4文字以上である必要があります';
    }
    return null;
  }
}

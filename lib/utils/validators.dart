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
}

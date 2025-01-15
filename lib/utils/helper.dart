import 'package:intl/intl.dart';

class Helper {
  // 日付をフォーマットする関数
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  // 年齢を計算する関数
  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // 文字列が空かどうかをチェックする関数
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // メールアドレスのバリデーション
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
} 
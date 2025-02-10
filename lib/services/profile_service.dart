import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/user.dart';

class ProfileService {
  Future<User> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        // APIレスポンスをパース
        final Map<String, dynamic> data = json.decode(response.body);

        // より柔軟なデータ抽出
        return User(
          name: _extractValue(data, ['username', 'name', 'displayName'], ''),
          gender: _extractValue(data, ['gender', 'sex'], '未設定'),
          age:
              _calculateAge(_extractValue(data, ['birthDate', 'birthday'], '')),
          birthday: _parseBirthday(
              _extractValue(data, ['birthDate', 'birthday'], '')),
          exerciseHabit:
              _extractValue(data, ['custom', 'exerciseHabit', 'exercise'], ''),
          sleepHours: _extractSleepHours(data),
          email: _extractValue(data, ['email'], 'guest@example.com'),
        );
      } else {
        throw Exception('プロフィール情報の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 複数のキーから値を安全に抽出
  String _extractValue(
      Map<String, dynamic> data, List<String> keys, String defaultValue) {
    for (var key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key].toString();
      }
    }
    return defaultValue;
  }

  // 睡眠時間を安全に抽出
  double _extractSleepHours(Map<String, dynamic> data) {
    final possibleKeys = ['sleepHours', 'sleep_hours', 'sleep'];
    for (var key in possibleKeys) {
      if (data.containsKey(key)) {
        return double.tryParse(data[key].toString()) ?? 0.0;
      }
    }
    return 0.0;
  }

  // 生年月日を安全にパース
  DateTime _parseBirthday(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty)
      return DateTime.now();

    try {
      return DateTime.parse(birthDateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;

    try {
      DateTime birthDate = DateTime.parse(birthDateString);
      DateTime today = DateTime.now();

      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }
}

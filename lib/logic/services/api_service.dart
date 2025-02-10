import '../../data/models/user.dart';
import '../../data/models/program.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://your-api-endpoint.com/api';

  // デフォルトユーザーを作成するメソッドを追加
  User createDefaultUser() {
    return User(
      name: 'ゲストユーザー',
      gender: '未設定',
      age: 30,
      birthday: DateTime(1990, 1, 1),
      exerciseHabit: '週3回',
      sleepHours: 7.0,
      email: 'guest@example.com',
    );
  }

  // ネットワーク接続を確認
  Future<bool> checkNetworkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ユーザープロファイルを取得
  Future<User> fetchUserProfile(String userId) async {
    try {
      // ネットワーク接続を確認
      final hasConnection = await checkNetworkConnection();
      if (!hasConnection) {
        return createDefaultUser();
      }

      // 本番環境では実際のAPIエンドポイントを使用
      if (userId == 'dummy_user_id') {
        return createDefaultUser();
      }

      final response = await http.get(
        Uri.parse('https://api.example.com/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('Timeout', 408);
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        // エラー時にデフォルトユーザーを返す
        return createDefaultUser();
      }
    } catch (e) {
      // 例外発生時にデフォルトユーザーを返す
      return createDefaultUser();
    }
  }

  // ユーザープロファイルを更新
  Future<User> updateUserProfile(User user) async {
    try {
      final response = await http.put(
        Uri.parse('https://api.example.com/users/${user.email}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> updatedUserData = json.decode(response.body);
        return User.fromJson(updatedUserData);
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // ヘルスプログラムを取得
  Future<List<HealthProgram>> fetchHealthPrograms() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/health-programs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body
            .map((dynamic item) => HealthProgram.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load health programs');
      }
    } catch (e) {
      throw Exception('Error fetching health programs: $e');
    }
  }
}

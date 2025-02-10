import 'package:get/get.dart';
import 'package:mimi/env.dart';
import 'package:mimi/signup/controller/auth_token_controller.dart';

import '../../data/models/user.dart';
import '../../data/models/program.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = Env.apiUrl;

  // デフォルトユーザーを作成するメソッドを追加
  Future<void> createUser(User user) async {
    final token = Get.find<AuthTokenController>().token;
    if (token.isEmpty) {
      throw Exception('認証トークンが見つかりません');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ...user.toJson(),
        'prefecture': 'Tokyo',
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('ユーザー登録に失敗しました ${response.body}');
    }
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
  Future<User> fetchUserProfile() async {
    try {
      final controller = Get.find<AuthTokenController>();
      // トークンが空の場合、取得を試みる
      if (controller.token.isEmpty) {
        await controller.refreshToken();
      }

      final token = controller.token;
      if (token.isEmpty) {
        throw Exception('認証トークンが見つかりません');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        print('ユーザープロファイル取得エラー: ${response.statusCode}');
        return User.createDefaultUser();
      }
    } catch (e) {
      print('ユーザープロファイル取得の例外: $e');
      return User.createDefaultUser();
    }
  }

  // ユーザープロファイルを更新
  Future<void> updateUserProfile(UpdateUser user) async {
    final token = Get.find<AuthTokenController>().token;
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode != 204) {
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

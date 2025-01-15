import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import './api_service.dart';

class ApiCognitiveTestService {
  final ApiService _apiService = ApiService();

  Future<User> saveCognitiveTestResult({
    required User user, 
    required int cognitiveFunctionScore,
    String? cognitiveFunctionComment,
  }) async {
    try {
      // ローカルストレージに保存（常に最初に実行）
      await saveLocalCognitiveTestResult(
        score: cognitiveFunctionScore, 
        comment: cognitiveFunctionComment ?? '',
      );

      // ユーザーの認知機能スコアを更新
      User updatedUser = user.copyWith(
        cognitiveFunctionScore: cognitiveFunctionScore,
        cognitiveFunctionComment: cognitiveFunctionComment,
      );

      // サーバー接続を完全に無効化
      return updatedUser;
    } catch (e) {
      print('認知機能テスト結果の保存中にエラーが発生しました: $e');
      throw Exception('ユーザー情報の保存に失敗しました: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCognitiveTestHistory(String userId) async {
    try {
      // ローカルストレージから履歴を取得
      return await getLocalCognitiveTestHistories();
    } catch (e) {
      print('テスト履歴取得中にエラーが発生しました: $e');
      return [];
    }
  }

  // ローカルストレージに認知機能テスト結果を保存
  Future<void> saveLocalCognitiveTestResult({
    required int score, 
    required String comment
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // テスト履歴を取得・更新
      final histories = await getLocalCognitiveTestHistories();
      
      // 新しい履歴エントリを追加
      histories.add({
        'score': score,
        'comment': comment,
        'date': DateTime.now().toIso8601String(),
      });

      // 履歴を保存（最新の10件のみ）
      final limitedHistories = histories.length > 10 
        ? histories.sublist(histories.length - 10) 
        : histories;

      await prefs.setString('cognitive_test_histories', json.encode(limitedHistories));
      
      // 最新の結果を個別に保存（下位互換性のため）
      await prefs.setInt('local_cognitive_test_score', score);
      await prefs.setString('local_cognitive_test_comment', comment);
      await prefs.setString('local_cognitive_test_date', DateTime.now().toIso8601String());
    } catch (e) {
      print('ローカルストレージへの保存中にエラーが発生しました: $e');
      throw Exception('ローカルデータの保存に失敗しました');
    }
  }

  // ローカルストレージから認知機能テスト結果を取得
  Future<Map<String, dynamic>?> getLocalCognitiveTestResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final score = prefs.getInt('local_cognitive_test_score');
      final comment = prefs.getString('local_cognitive_test_comment');
      final date = prefs.getString('local_cognitive_test_date');

      if (score != null && comment != null && date != null) {
        return {
          'score': score,
          'comment': comment,
          'date': date,
        };
      }
      return null;
    } catch (e) {
      print('ローカルストレージからの読み取り中にエラーが発生しました: $e');
      return null;
    }
  }

  // ローカルストレージからテスト履歴を取得
  Future<List<Map<String, dynamic>>> getLocalCognitiveTestHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiesJson = prefs.getString('cognitive_test_histories');
      
      if (historiesJson != null) {
        final List<dynamic> histories = json.decode(historiesJson);
        return histories.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('テスト履歴の取得中にエラーが発生しました: $e');
      return [];
    }
  }
} 
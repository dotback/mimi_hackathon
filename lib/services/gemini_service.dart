import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart' as local_user;
import '../env.dart';

class GeminiService {
  final GenerativeModel _generativeModel;

  GeminiService()
      : _generativeModel = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: Env.geminiApiKey,
        );

  Future<Map<String, dynamic>> generatePersonalizedTest(
      Map<String, dynamic> cognitiveTestResult,
      local_user.User userData) async {
    try {
      final prompt = '''
認知症予防のためのパーソナライズされた認知機能テストを作成してください。

ユーザープロファイル:
- 年齢: ${userData.age}歳
- 性別: ${userData.gender}
- 睡眠時間: ${userData.sleepHours}時間
- 運動習慣: ${userData.exerciseHabit}

直近の認知機能テスト結果:
- スコア: ${cognitiveTestResult['score']} / 10
- コメント: ${cognitiveTestResult['comment']}

テストの要件:
1. 2つの異なるタイプの問題を作成:
   a) 通常問題
   b) 音声問題

2. 問題のテンプレート例:
通常問題の例:
{
  "type": "通常問題",
  "category": "記憶力",
  "question": "1週間前の出来事を具体的に思い出せますか？",
  "options": [
    "はい、詳細に覚えています",
    "おおよそ覚えています", 
    "ほとんど覚えていません",
    "全く覚えていません"
  ],
  "correctAnswer": "はい、詳細に覚えています"
}

音声問題の例:
{
  "type": "音声問題",
  "category": "言語能力",
  "question": "あなたの子供の頃について教えてください,
  "correctAnswer": "子供の頃について3個以上の物事について話せると正解です"
}

3. 問題の難易度は、年齢と直近のテストスコアに基づいて調整してください。
   - テストスコアが低い場合は、より簡単な問題
   - テストスコアが高い場合は、より難しい問題

4. JSONフォーマットで返してください：
{
  "dailyProblems": [
    {
      "type": "通常問題" または "音声問題",
      "category": "記憶力" または "注意力" または "言語能力" など,
      "question": "問題文",
      "options": ["選択肢1", "選択肢2", "選択肢3", "選択肢4"],
      "correctAnswer": "正解の選択肢"
    }
  ]
}
''';

      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);

      // JSONを抽出して解析
      final parsedResponse = _extractJsonFromResponse(response.text ?? '{}');

      // ローカルストレージに保存
      await _saveGeneratedTest(parsedResponse);

      return parsedResponse;
    } catch (e) {
      print('Gemini APIエラー: $e');
      rethrow;
    }
  }

  // JSONを抽出するメソッドを改善
  Map<String, dynamic> _extractJsonFromResponse(String response) {
    try {
      // より高度なJSON抽出方法
      // コードブロック、バッククォート、JSONの可能性のある部分を探す
      final jsonMatches = RegExp(
              r'```json?\n?(.*?)```|\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\}',
              dotAll: true,
              multiLine: true)
          .allMatches(response);

      for (final match in jsonMatches) {
        String? potentialJson = match.group(0) ?? '';

        // バッククォートで囲まれたJSONの場合、内部のJSONを抽出
        if (potentialJson.startsWith('```')) {
          potentialJson = potentialJson
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }

        try {
          // JSONの妥当性を確認
          final parsedJson = json.decode(potentialJson);

          // 必要なキーが存在することを確認
          if (parsedJson is Map) {
            final dailyProblems = parsedJson['dailyProblems'];
            if (dailyProblems is List) {
              print('抽出に成功したJSON: $potentialJson');
              return {
                'dailyProblems': dailyProblems,
              };
            }
          }
        } catch (parseError) {
          print('JSON解析中のエラー: $parseError');
          continue;
        }
      }

      // デバッグ用のログ出力
      print('有効なJSONが見つかりませんでした。元のレスポンス: $response');

      return {'dailyProblems': []};
    } catch (e) {
      // エラーハンドリング
      print('JSON抽出中にエラーが発生しました: $e');
      return {'dailyProblems': []};
    }
  }

  Future<void> _saveGeneratedTest(Map<String, dynamic> test) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('personalized_test', json.encode(test));
  }

  Future<Map<String, dynamic>?> getLocalTest() async {
    final prefs = await SharedPreferences.getInstance();
    final testJson = prefs.getString('personalized_test');
    return testJson != null ? json.decode(testJson) : null;
  }
}

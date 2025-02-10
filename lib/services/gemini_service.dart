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
認知症予防のためのパーソナライズされた認知機能テストとToDOリストを作成してください。

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
   a) 通常問題（テキスト入力）
   b) 音声問題

2. 通常問題（テキスト入力）のテンプレート例:
{
  "type": "通常問題",
  "category": "言語能力",
  "title": "最近読んだ本について教えてください",
  "description": "最近読んだ本の題名、著者、そしてその本から学んだことや感銘を受けた部分について具体的に書いてください。", // ここがユーザーへの質問内容になります
  "correctAnswer": "具体的で詳細な回答を評価",
  "difficulty": 2
}

3. 音声問題の例:
{
  "type": "音声問題",
  "category": "言語能力",
  "question": "子供の頃の思い出を音声で話してください",
  "description": "子供の頃の思い出を詳細に話してください。",  // ここがユーザーへの質問内容になります
  "correctAnswer": "詳細に話せた",
  "difficulty": 2
}

4. 問題の難易度は、年齢と直近のテストスコアに基づいて調整してください。
   - テストスコアが低い場合は、より簡単な問題
   - テストスコアが高い場合は、より難しい問題

5. ToDoリストの要件
   - ユーザーの年齢、性別、睡眠時間、運動習慣に合わせたToDoリストを作成
   - 3つのToDoリストを作成
   - シンプルで明確な指示
   - 安全性を考慮
   - 認知機能に合わせた難易度

6. ToDoリストの例:
{
  "todoList": [
    {
      "title": "朝の体操",
      "description": "朝に体操をします",
      "icon": "アイコンの名前",
      "completed": false,
      "difficulty": 1, 2, または 3
    }
  ]
}

7. JSONフォーマットで返してください：
{
  "dailyProblems": [
    {
      "type": "通常問題",
      "category": "記憶力",
      "title": "1週間前の出来事を思い出せますか？",
      "description": "通常問題",
      "correctAnswer": "正確に出来事を説明できること",
      "difficulty": 2
    },
    {
      "type": "音声問題",
      "category": "言語能力",
      "title": "子供の頃の思い出を音声で話してください",
      "description": "あなたの子供の頃の一番楽しかった思い出を話してください。",
      "correctAnswer": "詳細に話せた",
      "difficulty": 2
    }
  ],
  "todoList": [
    {
      "title": "朝の体操",
      "description": "朝に体操をします",
      "icon": "exercise",
      "completed": false,
      "difficulty": 2
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
            final todoList = parsedJson['todoList'];
            if (dailyProblems is List && todoList is List) {
              print('抽出に成功したJSON: $potentialJson');
              return {
                'dailyProblems': dailyProblems,
                'todoList': todoList,
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
    // dailyProblemsを直接保存
    await prefs.setString(
        'personalized_daily_problems', json.encode(test['dailyProblems']));
    // ToDoリストも別途保存
    await prefs.setString(
        'personalized_todo_list', json.encode(test['todoList']));
  }

  Future<Map<String, dynamic>?> getLocalTest() async {
    final prefs = await SharedPreferences.getInstance();
    final testJson = prefs.getString('personalized_test');
    return testJson != null ? json.decode(testJson) : null;
  }

  Future<List<dynamic>> getLocalTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoJson = prefs.getString('personalized_todo_list');

    if (todoJson != null) {
      return json.decode(todoJson);
    }

    return [];
  }
}

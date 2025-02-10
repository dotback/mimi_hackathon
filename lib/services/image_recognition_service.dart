import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';

class ImageRecognitionService {
  final GenerativeModel _generativeModel;

  ImageRecognitionService(String apiKey)
      : _generativeModel = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
        );

  Future<Map<String, dynamic>> generateImageProblem(String imagePath) async {
    try {
      // アセットから画像をバイトデータとして読み込む
      final ByteData imageData = await rootBundle.load(imagePath);
      final Uint8List uint8List = imageData.buffer.asUint8List();

      const prompt = '''
      この画像について、認知症患者向けの問題を作成してください。以下のJSONフォーマットで返してください：

      {
        "problem": "問題文",
        "correctAnswer": "正解",
        "hints": "間違いやすいポイント",
        "improvements": "改善点"
      }

      画像の特徴を詳細に観察し、認知機能を刺激する問題を作成してください。
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', uint8List),
        ])
      ];

      // タイムアウト付きでリクエストを送信
      final response = await _generativeModel.generateContent(content).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Gemini APIのレスポンスがタイムアウトしました');
        },
      );

      // レスポンスからJSONを抽出
      final responseText = response.text ?? '';

      final jsonString = _extractJsonFromResponse(responseText);

      // JSONパースのエラーハンドリングを強化
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(jsonString);
      } catch (e) {
        return {
          'problem': '問題の生成中にエラーが発生しました',
          'correctAnswer': 'エラー',
          'hints': 'エラー',
          'improvements': 'システムエラーが発生しました',
        };
      }

      return {
        'problem': jsonMap['problem'] ?? '問題を生成できませんでした',
        'correctAnswer': jsonMap['correctAnswer'] ?? '正解が見つかりませんでした',
        'hints': jsonMap['hints'] ?? '特にヒントはありません',
        'improvements': jsonMap['improvements'] ?? '特に改善点はありません',
      };
    } catch (e, stackTrace) {
      return {
        'problem': '問題の生成中にエラーが発生しました',
        'correctAnswer': 'エラー',
        'hints': 'エラー',
        'improvements': 'システムエラーが発生しました',
      };
    }
  }

  Future<Map<String, dynamic>> evaluateAnswer({
    required String imagePath,
    required String problem,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    try {
      // アセットから画像をバイトデータとして読み込む
      final ByteData imageData = await rootBundle.load(imagePath);
      final Uint8List uint8List = imageData.buffer.asUint8List();

      final prompt = '''
      以下の情報に基づいて、ユーザーの回答を認知症患者の視点から優しく、温かく評価してください：

      問題: $problem
      正解: $correctAnswer
      ユーザーの回答: $userAnswer

      評価の観点：
      1. 回答が問題の意図を理解しているか
      2. 観察力と記憶力の発揮
      3. コミュニケーションの温かさ
      4. 認知的な努力の評価

      JSONレスポンスには以下の項目を含めてください：
      - isCorrect: 質問の意図を理解しているかのブール値
      - userAnswer: 元の回答テキスト
      - result: 回答の結果（「とても良い」「良い」「もう少し」など）
      - improvements: 優しく、励ましの言葉での改善提案
      - explanation: 温かく、共感的な回答分析

      JSONフォーマット例：
      {
        "isCorrect": true,
        "userAnswer": "回答テキスト",
        "result": "良い",
        "improvements": "観察力を更に磨いていきましょう。細かい部分にも注目してみてください。",
        "explanation": "あなたの回答は問題の本質をよく捉えています。少しずつ学んでいく姿勢が素晴らしいですね。"
      }

      優しく、温かく、励ましの気持ちを込めて評価してください。
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', uint8List),
        ])
      ];

      // タイムアウト付きでリクエストを送信
      final response = await _generativeModel.generateContent(content).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Gemini APIのレスポンスがタイムアウトしました');
        },
      );

      // レスポンスからJSONを抽出
      final responseText = response.text ?? '';

      final jsonString = _extractJsonFromResponse(responseText);

      // JSONパースのエラーハンドリングを強化
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(jsonString);
      } catch (e) {
        return {
          'isCorrect': false,
          'userAnswer': userAnswer,
          'result': '解析エラー',
          'improvements': 'システムの解析に問題が発生しました',
          'explanation': 'AIの応答形式に問題がありました: $e',
        };
      }

      return {
        'isCorrect': jsonMap['isCorrect'] ?? false,
        'userAnswer': jsonMap['userAnswer'] ?? userAnswer,
        'result': jsonMap['result'] ?? '評価できませんでした',
        'improvements': jsonMap['improvements'] ?? '特に改善点はありません',
        'explanation': jsonMap['explanation'] ?? '回答の分析ができませんでした',
      };
    } catch (e, stackTrace) {
      return {
        'isCorrect': false,
        'userAnswer': userAnswer,
        'result': '評価エラー',
        'improvements': '以下の点を確認してください：\n1. インターネット接続\n2. APIキーの有効性\n3. 回答の明瞭さ',
        'explanation': 'システムエラーが発生しました: ${e.toString()}',
      };
    }
  }

  // JSONを抽出するメソッドを改善
  String _extractJsonFromResponse(String response) {
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
          if (parsedJson is Map &&
              (parsedJson.containsKey('problem') ||
                  parsedJson.containsKey('correctAnswer') ||
                  parsedJson.containsKey('isCorrect'))) {
            return potentialJson;
          }
        } catch (parseError) {
          continue;
        }
      }

      return '{}';
    } catch (e) {
      return '{}';
    }
  }
}

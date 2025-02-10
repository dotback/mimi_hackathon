import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../env.dart';

class AnswerEvaluation {
  final bool isCorrect;
  final String result;
  final String userAnswer;
  final String improvements;
  final String explanation;

  AnswerEvaluation({
    required this.isCorrect,
    required this.result,
    required this.userAnswer,
    required this.improvements,
    required this.explanation,
  });

  AnswerEvaluation copyWith({
    bool? isCorrect,
    String? result,
    String? userAnswer,
    String? improvements,
    String? explanation,
  }) {
    return AnswerEvaluation(
      isCorrect: isCorrect ?? this.isCorrect,
      result: result ?? this.result,
      userAnswer: userAnswer ?? this.userAnswer,
      improvements: improvements ?? this.improvements,
      explanation: explanation ?? this.explanation,
    );
  }
}

class AnswerEvaluationService {
  final GenerativeModel _generativeModel;

  AnswerEvaluationService()
      : _generativeModel = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: Env.geminiApiKey,
        );

  Future<AnswerEvaluation> evaluateAnswer(
      String problemDescription, String userAnswer) async {
    try {
      final prompt = '''
認知症患者の学習と成長を支援する観点から、以下の問題と回答を優しく、温かく、建設的に評価してください：

問題文: $problemDescription

ユーザーの回答: $userAnswer

評価の観点：
1. 回答の理解度と努力
2. コミュニケーションの質
3. 認知的な挑戦への姿勢
4. 学習の可能性

JSONレスポンスには以下の項目を含めてください：
- isCorrect: 回答の質を反映するブール値（厳密な正解/不正解ではなく）
- result: 回答の総合的な評価（「とても良い」「良い」「もう少し」など）
- userAnswer: 元の回答テキスト
- improvements: 優しく、励ましの言葉での改善提案
- explanation: 温かく、共感的な回答分析

JSONフォーマット例：
{
  "isCorrect": true,
  "result": "とても良い取り組みです！",
  "userAnswer": "回答テキスト",
  "improvements": "次は更に詳しく説明してみましょう。あなたの観察力は素晴らしいです。",
  "explanation": "あなたの回答は問題の本質を捉えようとする姿勢が感じられます。小さな進歩を大切にしましょう。"
}

評価は厳しすぎず、常に励ましと温かさを忘れないでください。
''';

      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);

      // JSONを抽出して解析
      final parsedResponse = _extractJsonFromResponse(response.text ?? '{}');

      return AnswerEvaluation(
        isCorrect: parsedResponse['isCorrect'] ?? true,
        result: parsedResponse['result'] ?? '素晴らしい取り組みです！',
        userAnswer: userAnswer,
        improvements:
            parsedResponse['improvements'] ?? '更に成長できる可能性があります。頑張りましょう！',
        explanation: parsedResponse['explanation'] ?? '回答への真摯な取り組みを評価します。',
      );
    } catch (e) {
      print('回答評価エラー: $e');
      return AnswerEvaluation(
        isCorrect: false,
        result: '評価に少し時間がかかりました',
        userAnswer: userAnswer,
        improvements: '次はもっとゆっくり、丁寧に考えてみましょう。',
        explanation: 'システムの調子が少し悪いようです。でも大丈夫、一緒に頑張りましょう！',
      );
    }
  }

  // JSONを抽出するメソッド（gemini_serviceと同様の実装）
  Map<String, dynamic> _extractJsonFromResponse(String response) {
    try {
      final jsonMatches = RegExp(
              r'```json?\n?(.*?)```|\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\}',
              dotAll: true,
              multiLine: true)
          .allMatches(response);

      for (final match in jsonMatches) {
        String? potentialJson = match.group(0) ?? '';

        if (potentialJson.startsWith('```')) {
          potentialJson = potentialJson
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }

        try {
          final parsedJson = json.decode(potentialJson);

          if (parsedJson is Map) {
            // 必要なキーが存在することを確認
            final result = <String, dynamic>{};
            parsedJson.forEach((key, value) {
              result[key.toString()] = value;
            });

            if (result.containsKey('isCorrect') &&
                result.containsKey('result') &&
                result.containsKey('improvements') &&
                result.containsKey('explanation')) {
              return result;
            }
          }
        } catch (parseError) {
          print('JSON解析中のエラー: $parseError');
          continue;
        }
      }

      print('有効なJSONが見つかりませんでした。元のレスポンス: $response');
      return {};
    } catch (e) {
      print('JSON抽出中にエラーが発生しました: $e');
      return {};
    }
  }
}

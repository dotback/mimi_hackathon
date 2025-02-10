import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AnswerEvaluation {
  final bool isCorrect;
  final String userAnswer;
  final String result;
  final String improvements;
  final String explanation;

  AnswerEvaluation({
    required this.isCorrect,
    required this.userAnswer,
    required this.result,
    required this.improvements,
    required this.explanation,
  });

  // copyWithメソッドを追加
  AnswerEvaluation copyWith({
    bool? isCorrect,
    String? userAnswer,
    String? result,
    String? improvements,
    String? explanation,
  }) {
    return AnswerEvaluation(
      isCorrect: isCorrect ?? this.isCorrect,
      userAnswer: userAnswer ?? this.userAnswer,
      result: result ?? this.result,
      improvements: improvements ?? this.improvements,
      explanation: explanation ?? this.explanation,
    );
  }

  factory AnswerEvaluation.fromJson(Map<String, dynamic> json) {
    return AnswerEvaluation(
      isCorrect: json['isCorrect'] ?? false,
      userAnswer: json['userAnswer'] ?? '',
      result: json['result'] ?? '',
      improvements: json['improvements'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final GenerativeModel _generativeModel;

  SpeechService(String apiKey)
      : _generativeModel =
            GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  // テキストを音声に変換
  Future<void> speak(String text) async {
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.speak(text);
  }

  // 音声を文字に変換（ストリーミング形式）
  Future<String?> listen({
    VoidCallback? onSpeechStart,
    VoidCallback? onSpeechEnd,
    Function(String)? onPartialResult, // 新しいコールバック
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // マイクの権限を確認
    var micStatus = await Permission.microphone.request();

    if (micStatus != PermissionStatus.granted) {
      return null;
    }

    // 音声認識の初期化
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          onSpeechStart?.call();
        } else if (status == 'notListening') {
          onSpeechEnd?.call();
        }
      },
      onError: (error) {},
    );

    if (!available) {
      return null;
    }

    // 音声認識の開始
    final completer = Completer<String>();
    String recognizedText = '';

    _speechToText.listen(
      onResult: (result) {
        final currentWords = result.recognizedWords.trim();

        // 部分的な結果のコールバックを追加
        if (currentWords.isNotEmpty) {
          onPartialResult?.call(currentWords);
        }

        // 部分的な結果も蓄積
        if (currentWords.isNotEmpty) {
          recognizedText = currentWords;
        }

        // 最終結果の場合は確定
        if (result.finalResult) {
          if (recognizedText.isNotEmpty) {
            completer.complete(recognizedText);
          } else {}
        }
      },
      localeId: 'ja-JP',
      cancelOnError: true,
      partialResults: true, // 部分的な結果も受け取る
    );

    // タイムアウト設定
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        _speechToText.stop();

        // タイムアウト時に部分的に認識されたテキストがあれば返す
        if (recognizedText.isNotEmpty) {
          completer.complete(recognizedText);
        } else {
          completer.completeError('音声認識がタイムアウトしました');
        }
      }
    });

    try {
      final result = await completer.future;
      return result;
    } catch (e) {
      return null;
    } finally {
      onSpeechEnd?.call();
    }
  }

  // 音声ファイルからテキストを抽出
  Future<String?> transcribeAudioFile(String audioPath) async {
    try {
      // 音声認識の初期化
      bool available = await _speechToText.initialize(
        onStatus: (status) => {},
        onError: (error) {},
      );

      if (!available) {
        return null;
      }

      // 音声認識を開始
      final completer = Completer<String>();

      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedWords = result.recognizedWords.trim();
            if (recognizedWords.isNotEmpty) {
              completer.complete(recognizedWords);
            }
          }
        },
        localeId: 'ja-JP',
        cancelOnError: true,
        partialResults: false,
      );

      // タイムアウト設定
      Future.delayed(Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          _speechToText.stop();
          completer.completeError('音声認識がタイムアウトしました');
        }
      });

      try {
        final result = await completer.future;
        return result;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Geminiを使用した回答の詳細評価
  Future<AnswerEvaluation> evaluateAnswer(
      String question, String userAnswer) async {
    try {
      // 回答が空の場合の処理
      if (userAnswer.trim().isEmpty) {
        return AnswerEvaluation(
          isCorrect: false,
          userAnswer: userAnswer,
          result: '回答なし',
          improvements: '質問に対して何も話されていません',
          explanation: '音声認識に失敗したか、何も話されませんでした',
        );
      }

      // Speech to Textの結果をそのままGemini APIに送信
      final prompt = '''
      以下の質問と音声認識された回答について、認知症患者の言語能力を優しく、温かく評価してください：

      質問: $question
      音声認識された回答: $userAnswer

      評価の観点：
      1. 回答が質問の意図を理解しているか
      2. 感情や思い出を表現できているか
      3. コミュニケーションの温かさ
      4. 記憶の手がかりを提供できているか

      JSONレスポンスには以下の項目を含めてください：
      - isCorrect: 質問の意図を理解しているかのブール値
      - userAnswer: 音声認識された元の回答
      - result: 回答の結果（「とても良い」「良い」「もう少し」など）
      - improvements: 優しく、励ましの言葉での改善提案
      - explanation: 温かく、共感的な回答分析

      JSONフォーマット例：
      {
        "isCorrect": true,
        "userAnswer": "音声認識された回答",
        "result": "とても良い",
        "improvements": "素晴らしい思い出を話してくれてありがとうございます。もっと詳しく教えてもらえると嬉しいです。",
        "explanation": "あなたの大切な思い出を聞けて、とても嬉しいです。"
      }

      優しく、温かく、励ましの気持ちを込めて評価してください。
      ''';

      final content = [Content.text(prompt)];

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
        return AnswerEvaluation(
          isCorrect: false,
          userAnswer: userAnswer,
          result: '解析エラー',
          improvements: 'システムの解析に問題が発生しました',
          explanation: 'AIの応答形式に問題がありました: $e',
        );
      }

      return AnswerEvaluation.fromJson(jsonMap);
    } catch (e, stackTrace) {
      return AnswerEvaluation(
        isCorrect: false,
        userAnswer: userAnswer,
        result: '評価エラー',
        improvements: '以下の点を確認してください：\n1. インターネット接続\n2. APIキーの有効性\n3. 音声の明瞭さ',
        explanation: 'システムエラーが発生しました: ${e.toString()}',
      );
    }
  }

  // JSONを抽出するメソッドを改善
  String _extractJsonFromResponse(String response) {
    try {
      // より単純で安全なJSON抽出方法
      final jsonMatches =
          RegExp(r'\{[^{}]*\}', multiLine: true).allMatches(response);

      for (final match in jsonMatches) {
        try {
          final potentialJson = match.group(0) ?? '';

          // JSONの基本的な構造をチェック
          if (potentialJson.contains('"isCorrect"') &&
              potentialJson.contains('"userAnswer"') &&
              potentialJson.contains('"result"')) {
            // JSONの妥当性を確認
            json.decode(potentialJson);
            return potentialJson;
          }
        } catch (_) {
          // 無効なJSONは無視
          continue;
        }
      }

      return '{}';
    } catch (e) {
      // エラーハンドリング
      return '{}';
    }
  }

  // リソースの解放
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
  }

  // マイク権限の確認メソッドを追加
  Future<bool> checkMicPermission() async {
    var micStatus = await Permission.microphone.request();
    return micStatus == PermissionStatus.granted;
  }
}

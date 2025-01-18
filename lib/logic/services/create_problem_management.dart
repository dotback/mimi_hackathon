import 'package:flutter/foundation.dart';
import 'gemini_problem_generation_service.dart';
import 'normal_problem_service.dart';
import 'other_problem_service.dart';
import 'recall_problem_service.dart';
import 'speech_problem_service.dart';
import '../../data/models/user.dart';

class CreateProblemManagement {
  final GeminiProblemGenerationService _geminiService =
      GeminiProblemGenerationService();
  final NormalProblemService _normalProblemService = NormalProblemService();
  final OtherProblemService _otherProblemService = OtherProblemService();
  final RecallProblemService _recallProblemService = RecallProblemService();
  final SpeechProblemService _speechProblemService = SpeechProblemService();

  Future<void> generateProblems(
      User user, Map<String, dynamic> cognitiveTestResult) async {
    try {
      // Geminiから問題生成の指示を取得
      final instructions = await _geminiService.generateProblemInstructions(
          user, cognitiveTestResult);

      // 各サービスに問題生成を指示
      await _generateNormalProblems(instructions['normal_problems']);
      await _generateOtherProblems(instructions['other_problems']);
      await _generateRecallProblems(instructions['recall_problems']);
      await _generateSpeechProblems(instructions['speech_problems']);
    } catch (e) {
      debugPrint('問題生成エラー: $e');
    }
  }

  Future<void> _generateNormalProblems(
      Map<String, dynamic> instructions) async {
    final problems = await _normalProblemService.generateProblems(
      difficulty: instructions['difficulty'],
    );
    await _normalProblemService.saveProblems(problems);
  }

  Future<void> _generateOtherProblems(Map<String, dynamic> instructions) async {
    final problems = await _otherProblemService.generateProblems(
      difficulty: instructions['difficulty'],
    );
    await _otherProblemService.saveProblems(problems);
  }

  Future<void> _generateRecallProblems(
      Map<String, dynamic> instructions) async {
    final problems = await _recallProblemService.generateProblems(
      difficulty: instructions['difficulty'],
    );
    await _recallProblemService.saveProblems(problems);
  }

  Future<void> _generateSpeechProblems(
      Map<String, dynamic> instructions) async {
    final problems = await _speechProblemService.generateProblems(
      difficulty: instructions['difficulty'],
    );
    await _speechProblemService.saveProblems(problems);
  }
}

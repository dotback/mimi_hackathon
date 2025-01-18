import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/problem.dart';
import '../../data/models/user.dart';

class GeminiProblemGenerationService {
  Future<Map<String, dynamic>> generateProblemInstructions(
      User user, Map<String, dynamic> testResult) async {
    // Gemini APIの代わりにローカルでの問題生成ロジック
    final int score = testResult['score'];
    final String comment = testResult['comment'];

    return {
      'normal_problems': _generateNormalProblemInstructions(score),
      'other_problems': _generateOtherProblemInstructions(score),
      'recall_problems': _generateRecallProblemInstructions(score),
      'speech_problems': _generateSpeechProblemInstructions(score),
    };
  }

  Map<String, dynamic> _generateNormalProblemInstructions(int score) {
    return {
      'difficulty': _calculateDifficulty(score),
      'focus_areas': _getNormalProblemFocusAreas(score),
      'problem_types': ['calculation', 'logic']
    };
  }

  Map<String, dynamic> _generateOtherProblemInstructions(int score) {
    return {
      'difficulty': _calculateDifficulty(score),
      'focus_areas': _getOrientationProblemFocusAreas(score),
      'problem_types': ['time', 'location', 'date']
    };
  }

  Map<String, dynamic> _generateRecallProblemInstructions(int score) {
    return {
      'difficulty': _calculateDifficulty(score),
      'focus_areas': _getRecallProblemFocusAreas(score),
      'memory_types': ['short_term', 'word', 'image']
    };
  }

  Map<String, dynamic> _generateSpeechProblemInstructions(int score) {
    return {
      'difficulty': _calculateDifficulty(score),
      'focus_areas': _getSpeechProblemFocusAreas(score),
      'language_skills': ['vocabulary', 'pronunciation', 'comprehension']
    };
  }

  int _calculateDifficulty(int score) {
    if (score >= 8) return 3;
    if (score >= 5) return 2;
    return 1;
  }

  List<String> _getNormalProblemFocusAreas(int score) {
    if (score >= 8) return ['advanced_calculation', 'complex_logic'];
    if (score >= 5) return ['basic_calculation', 'simple_logic'];
    return ['fundamental_calculation', 'basic_reasoning'];
  }

  List<String> _getOrientationProblemFocusAreas(int score) {
    if (score >= 8) return ['precise_time', 'detailed_location'];
    if (score >= 5) return ['general_time', 'basic_location'];
    return ['current_time', 'immediate_environment'];
  }

  List<String> _getRecallProblemFocusAreas(int score) {
    if (score >= 8) return ['complex_memory', 'multi_step_recall'];
    if (score >= 5) return ['moderate_memory', 'sequential_recall'];
    return ['simple_memory', 'immediate_recall'];
  }

  List<String> _getSpeechProblemFocusAreas(int score) {
    if (score >= 8) return ['advanced_vocabulary', 'complex_sentences'];
    if (score >= 5) return ['intermediate_vocabulary', 'simple_conversation'];
    return ['basic_vocabulary', 'word_recognition'];
  }

  Future<User> fetchUserProfile(String userId) async {
    // 実際のアプリでは、APIやデータベースからユーザー情報を取得
    return User(
      name: 'テストユーザー',
      email: 'test@example.com',
      age: 65,
      gender: 'male',
      exerciseHabit: '週3回',
      sleepHours: 7.0,
      birthday: DateTime(1960, 1, 1),
    );
  }
}

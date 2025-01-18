import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/problem.dart';

class SpeechProblemService {
  Future<List<Problem>> generateProblems({int difficulty = 2}) async {
    // 難易度に応じた言語問題を生成
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '言語能力問題',
        description: '難易度$difficultyの言語能力問題',
        category: ProblemCategory.language,
        difficulty: difficulty,
        question: '動物の名前をできるだけ多く言ってください',
        answers: ['犬', '猫', '鳥', '魚', '馬'],
      )
    ];
  }

  Future<void> saveProblems(List<Problem> problems) async {
    // 問題をローカルストレージに保存
    final prefs = await SharedPreferences.getInstance();
    final problemsJson = problems.map((p) => p.toJson()).toList();
    await prefs.setStringList(
        'speech_problems', problemsJson.map((p) => json.encode(p)).toList());
  }
}

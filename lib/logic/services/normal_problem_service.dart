import '../../data/models/problem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NormalProblemService {
  Future<List<Problem>> generateProblems({int difficulty = 2}) async {
    // 難易度に応じた通常問題を生成
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '通常問題',
        description: '難易度$difficultyの通常問題',
        category: ProblemCategory.calculation,
        difficulty: difficulty,
      )
    ];
  }

  Future<void> saveProblems(List<Problem> problems) async {
    // 問題をローカルストレージに保存
    final prefs = await SharedPreferences.getInstance();
    final problemsJson = problems.map((p) => p.toJson()).toList();
    await prefs.setStringList(
        'normal_problems', problemsJson.map((p) => json.encode(p)).toList());
  }
}

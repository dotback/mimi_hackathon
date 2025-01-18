import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/problem.dart';

class OtherProblemService {
  Future<List<Problem>> generateProblems({int difficulty = 2}) async {
    // 難易度に応じた他の種類の問題を生成
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '他の種類の問題',
        description: '難易度$difficultyの他の種類の問題',
        category: ProblemCategory.orientation,
        difficulty: difficulty,
      )
    ];
  }

  Future<void> saveProblems(List<Problem> problems) async {
    // 問題をローカルストレージに保存
    final prefs = await SharedPreferences.getInstance();
    final problemsJson = problems.map((p) => p.toJson()).toList();
    await prefs.setStringList(
        'other_problems', problemsJson.map((p) => json.encode(p)).toList());
  }
}

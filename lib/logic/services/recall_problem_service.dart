import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/problem.dart';

class RecallProblemService {
  Future<List<Problem>> generateProblems({int difficulty = 2}) async {
    // 難易度に応じた想起問題を生成
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '想起問題',
        description: '難易度$difficultyの想起問題',
        category: ProblemCategory.recall,
        difficulty: difficulty,
        question: '先ほど覚えた単語を思い出してください',
        answers: ['りんご', '電車', '青空'],
      )
    ];
  }

  Future<void> saveProblems(List<Problem> problems) async {
    // 問題をローカルストレージに保存
    final prefs = await SharedPreferences.getInstance();
    final problemsJson = problems.map((p) => p.toJson()).toList();
    await prefs.setStringList(
        'recall_problems', problemsJson.map((p) => json.encode(p)).toList());
  }
}

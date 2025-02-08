import '../../data/models/problem.dart';
import '../../data/models/problem_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProblemService {
  Future<List<Problem>> generateDailyProblems() async {
    return [
      // 記憶力問題
      Problem(
        id: 'memory_1',
        title: '数字の記憶',
        description: '以下の数字を順番に覚えてください: 7, 3, 9, 2, 5',
        category: ProblemCategory.memory,
        difficulty: 2,
        correctAnswer: '7, 3, 9, 2, 5',
      ),
      // 計算問題
      Problem(
        id: 'calculation_1',
        title: '簡単な計算',
        description: '17 + 25 = ?',
        category: ProblemCategory.calculation,
        difficulty: 1,
        correctAnswer: 42,
      ),
      // 言語能力問題
      Problem(
        id: 'language_1',
        title: '思い出の共有',
        description: '子供の頃、最も楽しかった遊びは何ですか？',
        category: ProblemCategory.language,
        difficulty: 1,
        correctAnswer: '子供の頃の遊びについての個人的な思い出',
      ),
      Problem(
        id: 'language_2',
        title: '家族の思い出',
        description: 'あなたの家族で一番大切な人は誰ですか？その理由を教えてください。',
        category: ProblemCategory.language,
        difficulty: 1,
        correctAnswer: '家族への愛情や思い出についての個人的な回答',
      ),
      Problem(
        id: 'language_3',
        title: '好きな季節',
        description: 'あなたの一番好きな季節はいつですか？その理由を教えてください。',
        category: ProblemCategory.language,
        difficulty: 1,
        correctAnswer: '季節の好みと理由についての個人的な回答',
      ),
    ];
  }

  Future<void> saveProblemResult(ProblemResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('problem_results') ?? [];

    resultsJson.add(json.encode(result.toJson()));
    await prefs.setStringList('problem_results', resultsJson);
  }

  Future<List<ProblemResult>> getProblemResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('problem_results') ?? [];

    return resultsJson
        .map((resultJson) => ProblemResult.fromJson(json.decode(resultJson)))
        .toList();
  }

  Future<Map<ProblemCategory, double>> getCategoryPerformance() async {
    final results = await getProblemResults();
    final categoryResults = <ProblemCategory, List<bool>>{};

    for (var result in results) {
      final problem = await _getProblemById(result.problemId);
      if (problem != null) {
        categoryResults
            .putIfAbsent(problem.category, () => [])
            .add(result.isCorrect);
      }
    }

    final categoryPerformance = <ProblemCategory, double>{};
    categoryResults.forEach((category, results) {
      categoryPerformance[category] = results.isEmpty
          ? 0.0
          : results.where((r) => r).length / results.length;
    });

    return categoryPerformance;
  }

  Future<Problem?> _getProblemById(String id) async {
    final dailyProblems = await generateDailyProblems();
    final problems = dailyProblems.where((p) => p.id == id);
    return problems.isNotEmpty ? problems.first : null;
  }

  Future<List<ProblemResult>> getProblemResultTrends() async {
    final results = await getProblemResults();

    // パフォーマンスマップからProblemResultのリストを生成
    return results.map((result) {
      return ProblemResult(
        problemId: result.problemId,
        isCorrect: result.isCorrect,
        date: result.date,
        score: (result.score * 100).toInt(), // パーセンテージに変換
        timeTaken: result.timeTaken,
      );
    }).toList();
  }
}

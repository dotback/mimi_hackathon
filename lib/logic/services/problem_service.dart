import 'dart:math';
import '../../data/models/problem.dart';
import '../../data/models/problem_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProblemService {
  final _random = Random();

  Future<List<Problem>> generateDailyProblems() async {
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '記憶力テスト',
        description: '以下の3つの単語を覚えてください：りんご、電車、青空',
        category: ProblemCategory.memory,
        difficulty: 2,
      ),
      Problem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: '計算問題',
        description: '100から7を引いていってください',
        category: ProblemCategory.calculation,
        difficulty: 3,
      ),
      Problem(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: '言語能力テスト',
        description: '動物の名前をできるだけ多く言ってください',
        category: ProblemCategory.language,
        difficulty: 1,
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
    final performanceMap = await getCategoryPerformance();
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

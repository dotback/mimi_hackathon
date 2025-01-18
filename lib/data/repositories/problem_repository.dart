import '../../data/models/problem.dart';

class ProblemRepository {
  Future<List<Problem>> getProblems() async {
    return [
      Problem(
        id: '1',
        title: '問題1',
        description: 'これは問題1です',
        category: ProblemCategory.memory,
        difficulty: 1,
      ),
      Problem(
        id: '2',
        title: '問題2',
        description: 'これは問題2です',
        category: ProblemCategory.recall,
        difficulty: 2,
      ),
      Problem(
        id: '3',
        title: '問題3',
        description: 'これは問題3です',
        category: ProblemCategory.calculation,
        difficulty: 3,
      ),
    ];
  }

  Future<Problem?> getProblemById(String? id) async {
    if (id == null) return null;
    final problems = await getProblems();
    return problems.firstWhere((problem) => problem.id == id);
  }

  Future<List<Problem>> getProblemsByCategory(ProblemCategory? category) async {
    if (category == null) return [];
    final problems = await getProblems();
    return problems.where((problem) => problem.category == category).toList();
  }
}

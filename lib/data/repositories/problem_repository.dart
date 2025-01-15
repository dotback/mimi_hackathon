import '../data/models/problem.dart';

class ProblemRepository {
  final List<Problem> _problems = [];

  Future<List<Problem>> getAllProblems() async {
    // シミュレートされた遅延
    await Future.delayed(const Duration(milliseconds: 300));
    return _problems;
  }

  Future<Problem?> getProblemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _problems.firstWhere((problem) => problem.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Problem> createProblem(Problem problem) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _problems.add(problem);
    return problem;
  }

  Future<Problem?> updateProblem(Problem updatedProblem) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _problems.indexWhere((p) => p.id == updatedProblem.id);
    if (index != -1) {
      _problems[index] = updatedProblem;
      return updatedProblem;
    }
    return null;
  }

  Future<bool> deleteProblem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final initialLength = _problems.length;
    _problems.removeWhere((problem) => problem.id == id);
    return _problems.length < initialLength;
  }

  Future<List<Problem>> getProblemsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _problems.where((problem) => problem.category == category).toList();
  }
} 
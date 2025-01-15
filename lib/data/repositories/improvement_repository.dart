import '../data/models/improvement.dart';

class ImprovementRepository {
  final List<Improvement> _improvements = [];

  Future<List<Improvement>> getAllImprovements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _improvements;
  }

  Future<Improvement?> getImprovementById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _improvements.firstWhere((improvement) => improvement.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Improvement> createImprovement(Improvement improvement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _improvements.add(improvement);
    return improvement;
  }

  Future<Improvement?> updateImprovement(Improvement updatedImprovement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _improvements.indexWhere((i) => i.id == updatedImprovement.id);
    if (index != -1) {
      _improvements[index] = updatedImprovement;
      return updatedImprovement;
    }
    return null;
  }

  Future<bool> deleteImprovement(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final initialLength = _improvements.length;
    _improvements.removeWhere((improvement) => improvement.id == id);
    return _improvements.length < initialLength;
  }

  Future<List<Improvement>> getImprovementsByPriority(String priority) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _improvements.where((improvement) => improvement.priority == priority).toList();
  }

  Future<List<Improvement>> getCompletedImprovements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _improvements.where((improvement) => improvement.isCompleted).toList();
  }
} 
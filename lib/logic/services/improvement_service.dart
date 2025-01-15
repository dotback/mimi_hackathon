import 'dart:math';
import '../../data/models/improvement.dart';
import '../../data/repositories/improvement_repository.dart';

class ImprovementService {
  final ImprovementRepository improvementRepository;

  ImprovementService(this.improvementRepository);

  Future<Improvement> generateImprovement() async {
    final random = Random();
    final improvements = [
      '集中力を高める',
      '記憶力を改善する',
      '学習時間を増やす',
      '睡眠の質を向上させる',
      '健康的な食生活を心がける',
    ];

    final priorities = ['low', 'medium', 'high'];

    return Improvement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: improvements[random.nextInt(improvements.length)],
      priority: priorities[random.nextInt(priorities.length)],
    );
  }

  Future<Improvement> saveImprovement(Improvement improvement) async {
    return await improvementRepository.createImprovement(improvement);
  }

  Future<List<Improvement>> getPrioritizedImprovements() async {
    final improvements = await improvementRepository.getAllImprovements();
    
    // 優先度に基づいてソート
    improvements.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      return priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!);
    });

    return improvements;
  }

  Future<Improvement?> updateImprovementStatus(String id, bool isCompleted) async {
    final improvement = await improvementRepository.getImprovementById(id);
    
    if (improvement != null) {
      final updatedImprovement = Improvement(
        id: improvement.id,
        description: improvement.description,
        priority: improvement.priority,
        isCompleted: isCompleted,
        createdAt: improvement.createdAt,
      );

      return await improvementRepository.updateImprovement(updatedImprovement);
    }

    return null;
  }
} 
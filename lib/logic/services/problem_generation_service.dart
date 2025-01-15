import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';

abstract class ProblemGenerationService {
  final ProblemRepository problemRepository;

  ProblemGenerationService(this.problemRepository);

  // 共通の問題生成メソッド
  Future<Problem> generateProblem();

  // 難易度に基づいて問題を生成
  Future<Problem> generateProblemByDifficulty(String difficulty) async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: problem.question,
      answers: problem.answers,
      difficulty: difficulty,
      category: problem.category,
      imagePath: problem.imagePath,
    );
  }

  // カテゴリに基づいて問題を生成
  Future<Problem> generateProblemByCategory(String category) async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: problem.question,
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: category,
      imagePath: problem.imagePath,
    );
  }

  // 問題を保存
  Future<Problem> saveProblem(Problem problem) async {
    return await problemRepository.createProblem(problem);
  }
} 
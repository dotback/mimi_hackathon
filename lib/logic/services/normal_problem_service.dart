import 'dart:math';
import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';
import 'problem_generation_service.dart';

class NormalProblemService extends ProblemGenerationService {
  NormalProblemService(ProblemRepository problemRepository) 
      : super(problemRepository);

  @override
  Future<Problem> generateProblem() async {
    // ダミーの問題生成ロジック
    final categories = ['math', 'language', 'science', 'history'];
    final difficulties = ['easy', 'medium', 'hard'];
    
    final random = Random();
    
    final problem = Problem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: _generateRandomQuestion(),
      answers: [_generateRandomAnswer()],
      difficulty: difficulties[random.nextInt(difficulties.length)],
      category: categories[random.nextInt(categories.length)],
    );

    return problem;
  }

  String _generateRandomQuestion() {
    final questions = [
      '2 + 2 は何ですか？',
      '東京の首都は何ですか？',
      '水の沸点は何度ですか？',
      '日本で最も高い山は？',
    ];
    final random = Random();
    return questions[random.nextInt(questions.length)];
  }

  String _generateRandomAnswer() {
    final answers = [
      '4',
      '日本',
      '100度',
      '富士山',
    ];
    final random = Random();
    return answers[random.nextInt(answers.length)];
  }
} 
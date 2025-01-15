import 'dart:math';
import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';
import 'problem_generation_service.dart';

class RecallProblemService extends ProblemGenerationService {
  RecallProblemService(ProblemRepository problemRepository) 
      : super(problemRepository);

  @override
  Future<Problem> generateProblem() async {
    final random = Random();
    
    final recallImages = [
      'assets/images/animal1.jpg',
      'assets/images/landmark1.jpg',
      'assets/images/object1.jpg',
      'assets/images/food1.jpg',
    ];

    final recallQuestions = [
      'この画像に写っているものは何ですか？',
      'この画像の中の動物の名前は？',
      'この画像の風景はどこですか？',
      'この画像の料理の名前は？',
    ];

    final recallAnswers = [
      '動物',
      '犬',
      '東京タワー',
      '寿司',
    ];

    final difficulties = ['easy', 'medium', 'hard'];
    final categories = ['visual_recall', 'memory', 'observation'];

    final problem = Problem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: recallQuestions[random.nextInt(recallQuestions.length)],
      answers: [recallAnswers[random.nextInt(recallAnswers.length)]],
      difficulty: difficulties[random.nextInt(difficulties.length)],
      category: categories[random.nextInt(categories.length)],
      imagePath: recallImages[random.nextInt(recallImages.length)],
    );

    return problem;
  }

  // 画像認識に基づいた追加のメソッド
  Future<Problem> generateImageRecallProblem(String imagePath) async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: problem.question,
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: problem.category,
      imagePath: imagePath,
    );
  }
} 
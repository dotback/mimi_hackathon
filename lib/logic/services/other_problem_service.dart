import 'dart:math';
import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';
import 'problem_generation_service.dart';

class OtherProblemService extends ProblemGenerationService {
  OtherProblemService(ProblemRepository problemRepository) 
      : super(problemRepository);

  @override
  Future<Problem> generateProblem() async {
    final random = Random();
    
    final otherQuestions = [
      '次の論理パズルを解いてください：',
      '与えられた情報から最適な結論を導き出してください：',
      '創造的な問題解決を示してください：',
      '感情的知性を必要とする状況を分析してください：',
    ];

    final otherQuestionDetails = [
      'AはBより背が高く、CはAより背が低いです。誰が一番背が高いですか？',
      '3人の友人がいます。それぞれ異なる職業を持っています。手がかりから職業を特定してください。',
      'リソースが限られている状況で、チームの生産性を最大化する方法は？',
      '対立する意見を持つ2人の同僚の間に立って、解決策を提案してください。',
    ];

    final otherAnswers = [
      'B',
      '教師、エンジニア、医者',
      'チームメンバーの強みを活かし、タスクを最適化する',
      '両者の視点を理解し、妥協点を見つける',
    ];

    final difficulties = ['easy', 'medium', 'hard'];
    final categories = ['logic', 'creativity', 'emotional_intelligence', 'problem_solving'];

    final problem = Problem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: otherQuestions[random.nextInt(otherQuestions.length)] + 
                otherQuestionDetails[random.nextInt(otherQuestionDetails.length)],
      answers: [otherAnswers[random.nextInt(otherAnswers.length)]],
      difficulty: difficulties[random.nextInt(difficulties.length)],
      category: categories[random.nextInt(categories.length)],
    );

    return problem;
  }

  // 論理パズル問題の生成
  Future<Problem> generateLogicPuzzleProblem() async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: '論理パズル：${problem.question}',
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: 'logic_puzzle',
    );
  }

  // 創造的思考問題の生成
  Future<Problem> generateCreativityProblem() async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: '創造的思考チャレンジ：${problem.question}',
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: 'creative_thinking',
    );
  }
} 
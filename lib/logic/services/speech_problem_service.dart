import 'dart:math';
import '../../data/models/problem.dart';
import '../../data/repositories/problem_repository.dart';
import 'problem_generation_service.dart';

class SpeechProblemService extends ProblemGenerationService {
  SpeechProblemService(ProblemRepository problemRepository) 
      : super(problemRepository);

  @override
  Future<Problem> generateProblem() async {
    final random = Random();
    
    final speechQuestions = [
      '次の文章を正確に発音してください：',
      '聞こえた音声の内容を書き取ってください：',
      '音声から聞き取った単語を選んでください：',
      '音声の感情を推測してください：',
    ];

    final speechTexts = [
      '私は毎日日本語を勉強しています。',
      'こんにちは、お元気ですか？',
      '東京は日本の首都です。',
      '私の趣味は読書と音楽を聴くことです。',
    ];

    final speechAnswers = [
      '私は毎日日本語を勉強しています。',
      'こんにちは、お元気ですか？',
      '東京',
      '前向き',
    ];

    final difficulties = ['easy', 'medium', 'hard'];
    final categories = ['pronunciation', 'listening', 'comprehension'];

    final problem = Problem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: speechQuestions[random.nextInt(speechQuestions.length)] + 
                speechTexts[random.nextInt(speechTexts.length)],
      answers: [speechAnswers[random.nextInt(speechAnswers.length)]],
      difficulty: difficulties[random.nextInt(difficulties.length)],
      category: categories[random.nextInt(categories.length)],
    );

    return problem;
  }

  // テキスト音声変換（Text-to-Speech）問題の生成
  Future<Problem> generateTextToSpeechProblem() async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: '次のテキストを音声で読み上げてください：\n${problem.question}',
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: 'text_to_speech',
    );
  }

  // 音声認識（Speech-to-Text）問題の生成
  Future<Problem> generateSpeechToTextProblem() async {
    final problem = await generateProblem();
    return Problem(
      id: problem.id,
      question: '聞こえた音声の内容を正確に書き取ってください。',
      answers: problem.answers,
      difficulty: problem.difficulty,
      category: 'speech_to_text',
    );
  }
} 
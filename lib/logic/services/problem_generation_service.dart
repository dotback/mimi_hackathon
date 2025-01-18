import '../../data/models/problem.dart';

class ProblemGenerationService {
  Future<List<Problem>> generateProblems() async {
    return [
      Problem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '問題1',
        description: 'これは問題1です',
        category: ProblemCategory.memory,
        difficulty: 2,
        question: 'これは記憶問題です',
        answers: ['はい', 'いいえ'],
      ),
      Problem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: '問題2',
        description: 'これは問題2です',
        category: ProblemCategory.recall,
        difficulty: 3,
        question: 'これは想起問題です',
        answers: ['はい', 'いいえ'],
        imagePath: 'assets/images/test.png',
      ),
      Problem(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: '問題3',
        description: 'これは問題3です',
        category: ProblemCategory.calculation,
        difficulty: 1,
      ),
    ];
  }
}

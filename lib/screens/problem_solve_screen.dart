import 'package:flutter/material.dart';
import '../data/models/problem.dart';

class ProblemSolveScreen extends StatefulWidget {
  final Problem problem;

  const ProblemSolveScreen({super.key, required this.problem});

  @override
  _ProblemSolveScreenState createState() => _ProblemSolveScreenState();
}

class _ProblemSolveScreenState extends State<ProblemSolveScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitted = false;
  bool _isCorrect = false;

  void _submitAnswer() {
    setState(() {
      _isSubmitted = true;
      _isCorrect = _checkAnswer(_answerController.text);
    });
  }

  bool _checkAnswer(String userAnswer) {
    // カテゴリに応じた簡単な正解判定
    switch (widget.problem.category) {
      case ProblemCategory.memory:
        return _checkMemoryAnswer(userAnswer);
      case ProblemCategory.recall:
        return _checkRecallAnswer(userAnswer);
      case ProblemCategory.calculation:
        return _checkCalculationAnswer(userAnswer);
      case ProblemCategory.orientation:
        return _checkOrientationAnswer(userAnswer);
      default:
        return userAnswer.trim().isNotEmpty;
    }
  }

  bool _checkMemoryAnswer(String userAnswer) {
    // メモリ問題の簡単な正解判定
    return userAnswer.trim() == widget.problem.correctAnswer.toString();
  }

  bool _checkRecallAnswer(String userAnswer) {
    // 想起力問題の簡単な正解判定
    return userAnswer.trim().isNotEmpty;
  }

  bool _checkCalculationAnswer(String userAnswer) {
    // 計算問題の正解判定
    try {
      return int.parse(userAnswer) == widget.problem.correctAnswer;
    } catch (e) {
      return false;
    }
  }

  bool _checkOrientationAnswer(String userAnswer) {
    // 見当識問題の簡単な正解判定
    return userAnswer.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.problem.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: '答えを入力してください',
                border: OutlineInputBorder(),
                enabled: !_isSubmitted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitted ? null : _submitAnswer,
              child: Text('解答する'),
            ),
            const SizedBox(height: 16),
            if (_isSubmitted)
              Text(
                _isCorrect ? '正解！🎉' : '不正解。もう一度挑戦してください。',
                style: TextStyle(
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

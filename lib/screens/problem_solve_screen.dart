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
        title: Text(
          widget.problem.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.problem.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  boxShadow: _isSubmitted
                      ? [
                          BoxShadow(
                            color: _isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: '答えを入力してください',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !_isSubmitted,
                    filled: true,
                    fillColor: _isSubmitted
                        ? (_isCorrect
                            ? Colors.green.shade50
                            : Colors.red.shade50)
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitted ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '解答する',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isSubmitted)
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isSubmitted ? 1.0 : 0.0,
                    child: Text(
                      _isCorrect ? '正解！🎉' : '不正解。もう一度挑戦してください。',
                      style: TextStyle(
                        color: _isCorrect ? Colors.green : Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

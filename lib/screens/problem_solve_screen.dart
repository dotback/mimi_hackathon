import 'package:flutter/material.dart';
import '../data/models/problem.dart';
import '../services/answer_evaluation_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProblemSolveScreen extends StatefulWidget {
  final Problem problem;

  const ProblemSolveScreen({super.key, required this.problem});

  @override
  _ProblemSolveScreenState createState() => _ProblemSolveScreenState();
}

class _ProblemSolveScreenState extends State<ProblemSolveScreen> {
  final TextEditingController _answerController = TextEditingController();
  final AnswerEvaluationService _evaluationService = AnswerEvaluationService();
  bool _isSubmitted = false;
  bool _isProcessing = false;
  AnswerEvaluation? _evaluation;

  void _submitAnswer() async {
    final userAnswer = _answerController.text.trim();

    if (userAnswer.isEmpty) {
      // 空の回答の場合は何もしない
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Gemini APIで回答を評価
      final evaluation = await _evaluationService.evaluateAnswer(
          widget.problem.description, userAnswer);

      setState(() {
        _isSubmitted = true;
        _isProcessing = false;
        _evaluation = evaluation;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      // エラーハンドリング
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('回答の評価中にエラーが発生しました: $e')),
      );
    }
  }

  // 結果の色を決定するメソッド
  Color _getResultColor(String result) {
    final lowercaseResult = result.toLowerCase();
    if (lowercaseResult.contains('とても良い') ||
        lowercaseResult.contains('素晴らしい')) {
      return Colors.green.shade700;
    } else if (lowercaseResult.contains('良い') ||
        lowercaseResult.contains('頑張')) {
      return Colors.blue.shade700;
    } else {
      return Colors.orange.shade700;
    }
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
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: '答えを入力してください',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabled: !_isSubmitted && !_isProcessing,
                  filled: true,
                  fillColor: _isSubmitted ? Colors.grey.shade100 : Colors.white,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitted || _isProcessing ? null : _submitAnswer,
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

              // 処理中インジケーター
              if (_isProcessing)
                Center(
                  child: Column(
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.blue,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gemini AIが回答を確認しています...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // 結果表示
              if (_isSubmitted && _evaluation != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 結果
                    Card(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'AIからの評価',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _evaluation!.result,
                              style: TextStyle(
                                color: _getResultColor(_evaluation!.result),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // あなたの回答
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'あなたの回答',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _evaluation!.userAnswer,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 改善点
                    Card(
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '学びのヒント',
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _evaluation!.improvements,
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 詳細説明
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '詳細な解説',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _evaluation!.explanation,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import '../logic/services/create_problem_management.dart';
import '../logic/services/gemini_problem_generation_service.dart';
import '../../data/models/user.dart';

class CognitiveTestScreen extends StatefulWidget {
  const CognitiveTestScreen({super.key});

  @override
  State<CognitiveTestScreen> createState() => _CognitiveTestScreenState();
}

class _CognitiveTestScreenState extends State<CognitiveTestScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '現在いる場所の種類を答えてください。',
      'type': 'location_type',
      'timeLimit': 30,
      'options': ['自宅', '職場', '公共施設', '屋外', 'その他', 'わからない'],
    },
    {
      'question': '今日の日付を答えてください。',
      'type': 'date',
      'correctAnswer': null,
      'timeLimit': 30,
      'options': null,
    },
    {
      'question': '以下の3つの単語を覚えてください：りんご、電車、青空',
      'type': 'memory',
      'memorizedWords': ['りんご', '電車', '青空'],
      'timeLimit': 20,
      'options': null,
    },
    {
      'question': '100から7を順番に引いていってください。',
      'type': 'math',
      'timeLimit': 60,
      'options': null,
    },
    {
      'question': '先ほど覚えた3つの単語を思い出してください。',
      'type': 'recall',
      'timeLimit': 30,
      'options': ['りんご', '電車', '青空', 'わからない'],
    },
    {
      'question': '今の季節はいつですか？',
      'type': 'season',
      'timeLimit': 30,
      'options': ['春', '夏', '秋', '冬', 'わからない'],
    },
    {
      'question': '以下の動物の名前を言ってください。',
      'type': 'animal',
      'timeLimit': 30,
      'options': ['犬', '猫', '鳥', 'わからない'],
    },
    {
      'question': '今から逆から100まで数えてください。',
      'type': 'reverse_math',
      'timeLimit': 60,
      'options': null,
    },
    {
      'question': '自分の生年月日を答えてください。',
      'type': 'birthday',
      'timeLimit': 30,
      'options': null,
    },
    {
      'question': '現在の時間を答えてください。',
      'type': 'time',
      'timeLimit': 30,
      'options': null,
    }
  ];

  final TextEditingController _textController = TextEditingController();
  int _currentQuestionIndex = 0;
  final List<String> _userAnswers = [];
  int _score = 0;
  Timer? _questionTimer;
  int _remainingTime = 0;
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;
  final _createProblemManagement = CreateProblemManagement();
  final _apiService = GeminiProblemGenerationService();

  @override
  void initState() {
    super.initState();
    _questions[1]['correctAnswer'] = _getCurrentDateString();
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _timerAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_timerAnimationController);
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _textController.dispose();
    _timerAnimationController.dispose();
    super.dispose();
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    return DateFormat('yyyy年M月d日').format(now);
  }

  void _startQuestionTimer() {
    _remainingTime = _questions[_currentQuestionIndex]['timeLimit'];
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _questionTimer?.cancel();
        _nextQuestion(null);
      }
    });
  }

  void _nextQuestion(String? answer, {bool skipped = false}) {
    _questionTimer?.cancel();
    _timerAnimationController.stop();

    if (!skipped && answer != null) {
      _userAnswers.add(answer);

      switch (_questions[_currentQuestionIndex]['type']) {
        case 'date':
          if (answer == _questions[_currentQuestionIndex]['correctAnswer']) {
            _score++;
          }
          break;
        case 'location_type':
        case 'season':
        case 'animal':
        case 'recall':
          if (_questions[_currentQuestionIndex]['options'].contains(answer)) {
            _score++;
          }
          break;
        // 他の質問タイプの採点ロジック
      }
    }

    _textController.clear();

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _startQuestionTimer();
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final resultComment = _getResultInterpretation();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('認知機能テスト結果'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('スコア: $_score / ${_questions.length}'),
              Text(
                resultComment,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _finishTest();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  String _getResultInterpretation() {
    if (_score >= 8) {
      return '認知機能は良好です。';
    } else if (_score >= 5) {
      return '軽度の認知機能低下の可能性があります。医療専門家に相談することをお勧めします。';
    } else {
      return '認知機能低下の兆候が見られます。早めに医療専門家に相談してください。';
    }
  }

  Widget _buildQuestionInput() {
    final question = _questions[_currentQuestionIndex];
    switch (question['type']) {
      case 'date':
        return CalendarDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onDateChanged: (date) {
            _nextQuestion(DateFormat('yyyy年M月d日').format(date));
          },
        );

      case 'location_type':
      case 'season':
      case 'animal':
      case 'recall':
        return Column(
          children: [
            ...question['options']
                .map<Widget>((option) => ElevatedButton(
                      onPressed: () => _nextQuestion(option),
                      child: Text(option),
                    ))
                .toList(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _nextQuestion('わからない'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('わからない'),
            ),
          ],
        );

      case 'memory':
        return Column(
          children: [
            Text(
              question['memorizedWords'].join(', '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _nextQuestion('覚えました'),
              child: const Text('覚えました'),
            ),
          ],
        );

      case 'math':
      case 'reverse_math':
        return ElevatedButton(
          onPressed: () => _nextQuestion('計算完了'),
          child: const Text('計算を完了'),
        );

      case 'birthday':
      case 'time':
      default:
        return TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: question['type'] == 'birthday'
                ? '例: 1980年1月1日'
                : '例: ${DateFormat('HH:mm').format(DateTime.now())}',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: _nextQuestion,
        );
    }
  }

  void _finishTest() async {
    int score = _calculateScore();
    String comment = _generateComment(score);

    // ユーザー情報を取得（仮）
    User user = await _apiService.fetchUserProfile('dummy_user_id');

    // 問題生成サービスに結果を渡す
    await _createProblemManagement.generateProblems(user, {
      'score': score,
      'comment': comment,
    });

    // ホーム画面に戻る
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          initialTestResult: {
            'score': score,
            'comment': comment,
          },
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // スコアを計算するメソッド
  int _calculateScore() {
    return _userAnswers.where((answer) => answer != null).length;
  }

  // スコアに基づいてコメントを生成
  String _generateComment(int score) {
    if (score >= 8) {
      return '認知機能は非常に良好です。現在の生活習慣を継続してください。';
    } else if (score >= 5) {
      return '認知機能は標準的です。さらなる改善の余地があります。';
    } else {
      return '認知機能の低下が見られます。医療専門家に相談することをお勧めします。';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('認知機能テスト'),
        actions: [
          TextButton(
            onPressed: () => _nextQuestion(null, skipped: true),
            child: const Text('スキップ'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _timerAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingTime <= 10 ? Colors.red : Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              '残り時間: $_remainingTime 秒',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildQuestionInput(),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import '../logic/services/gemini_problem_generation_service.dart';
import '../../data/models/user.dart';
import 'package:get/get.dart';

class CognitiveTestScreen extends StatefulWidget {
  const CognitiveTestScreen({super.key});

  @override
  State<CognitiveTestScreen> createState() => _CognitiveTestScreenState();
}

class _CognitiveTestScreenState extends State<CognitiveTestScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'あなたのお年はいくつですか?',
      'type': 'age',
      'timeLimit': 30,
      'options': null,
    },
    {
      'question': '今日は何年の何月何日ですか？また、何曜日ですか？',
      'type': 'detailed_date',
      'correctAnswer': null,
      'timeLimit': 30,
      'options': {
        'years': List.generate(10, (index) => DateTime.now().year - 5 + index)
            .map((e) => e.toString())
            .toList(),
        'months': List.generate(12, (index) => (index + 1).toString()),
        'days': List.generate(31, (index) => (index + 1).toString()),
        'weekdays': ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日']
      },
    },
    {
      'question': '私たちが今いる場所はどこですか？',
      'type': 'location_description',
      'timeLimit': 30,
      'options': null,
    },
    {
      'question': '今から表示される3つの単語を覚えてください',
      'type': 'memory_stage1',
      'memorizedWords': ['桜', '猫', '電車'],
      'timeLimit': 30,
      'multipleChoiceQuestions': [
        {
          'question': '最初の単語は何でしたか？',
          'options': ['森', '桜', '花', '風'],
          'correctAnswer': '桜'
        },
        {
          'question': '2番目の単語は何でしたか？',
          'options': ['犬', '猿', '猫', '狐'],
          'correctAnswer': '猫'
        },
        {
          'question': '最後の単語は何でしたか？',
          'options': ['電車', '車', '消防車', '救急車'],
          'correctAnswer': '電車'
        }
      ]
    },
    {
      'question': '今から数字が出るので逆の順番で回答してください',
      'type': 'reverse_number_memory',
      'memorizedWords': ['6', '8', '2', '9'],
      'timeLimit': 30,
      'multipleChoiceQuestions': [
        {
          'question': '最初の数字は何でしたか？',
          'options': ['2', '6', '8', '9'],
          'correctAnswer': '9'
        },
        {
          'question': '2番目の数字は何でしたか？',
          'options': ['6', '8', '2', '9'],
          'correctAnswer': '2'
        },
        {
          'question': '3番目の数字は何でしたか？',
          'options': ['6', '8', '2', '9'],
          'correctAnswer': '8'
        },
        {
          'question': '最後の数字は何でしたか？',
          'options': ['2', '6', '8', '9'],
          'correctAnswer': '6'
        }
      ]
    },
    {
      'question': '100から7を順番に引いてください。最初の数字を選んでください。',
      'type': 'math_stage1',
      'timeLimit': 30,
      'options': ['94', '93', '92', '91'],
      'correctAnswer': '93',
      'nextStage': {
        'question': '93から7を引いてください。',
        'type': 'math_stage1',
        'timeLimit': 30,
        'options': ['86', '87', '88', '89'],
        'correctAnswer': '86'
      }
    },
    {
      'question': '先ほど覚えた単語を再度回答してください',
      'type': 'memory_stage1',
      'memorizedWords': ['桜', '猫', '電車'],
      'timeLimit': 30,
      'multipleChoiceQuestions': [
        {
          'question': '最初の単語は何でしたか？',
          'options': ['森', '桜', '花', '風'],
          'correctAnswer': '桜'
        },
        {
          'question': '2番目の単語は何でしたか？',
          'options': ['犬', '猿', '猫', '狐'],
          'correctAnswer': '猫'
        },
        {
          'question': '最後の単語は何でしたか？',
          'options': ['電車', '車', '消防車', '救急車'],
          'correctAnswer': '電車'
        }
      ]
    },
    {
      'question': '今から画像を表示するので覚えてください',
      'type': 'image_memory',
      'images': [
        'assets/images/clock.png',
        'assets/images/key.png',
        'assets/images/pencil.png'
      ],
      'timeLimit': 30,
      'multipleChoiceQuestions': [
        {
          'question': '最初の画像は何でしたか？',
          'options': ['時計', 'コップ', '携帯電話', '扉'],
          'correctAnswer': '時計'
        },
        {
          'question': '2番目の画像は何でしたか？',
          'options': ['傘', '靴', '帽子', '鍵'],
          'correctAnswer': '鍵'
        },
        {
          'question': '最後の画像は何でしたか？',
          'options': ['カレンダー', '鉛筆', '水', '花'],
          'correctAnswer': '鉛筆'
        }
      ]
    },
    {
      'question': '知っている野菜の名前をできるだけ多く言ってください。',
      'type': 'vegetable_list',
      'timeLimit': 30,
      'options': null,
    },
  ];

  final TextEditingController _textController = TextEditingController();
  int _currentQuestionIndex = 0;
  final List<String> _userAnswers = [];
  int _score = 0;
  Timer? _questionTimer;
  int _remainingTime = 0;
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;
  final _apiService = GeminiProblemGenerationService();

  // クラスレベルで状態を管理
  bool _isTestCompleted = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    // 詳細な日付の正解を設定
    final now = DateTime.now();
    _questions[1]['correctAnswer'] = {
      'year': now.year.toString(),
      'month': now.month.toString(),
      'day': now.day.toString(),
      'weekday': _getWeekdayString(now.weekday)
    };

    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _timerAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_timerAnimationController);

    // テスト開始前に説明ダイアログを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTestInstructionsDialog();
    });

    // initStateでは一時的にタイマーを停止
    _timerAnimationController.stop();
    _questionTimer?.cancel();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _textController.dispose();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    // テストが既に完了している場合は何もしない
    if (_isTestCompleted || _currentQuestionIndex >= _questions.length) {
      return;
    }

    // 既存のタイマー初期化処理
    _remainingTime = _questions[_currentQuestionIndex]['timeLimit'];
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    _questionTimer?.cancel();

    // メモリーテストの場合は選択画面になるまでタイマーを開始しない
    if (_questions[_currentQuestionIndex]['type'] == 'memory_stage1' ||
        _questions[_currentQuestionIndex]['type'] == 'reverse_number_memory') {
      return;
    }

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // テストが既に完了している場合はタイマーを停止
      if (_isTestCompleted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        timer.cancel();

        // 最後の問題でない場合のみ次の問題に進む
        if (_currentQuestionIndex < _questions.length - 1) {
          _nextQuestion(null);
        } else {
          // テストを最終確定
          _finalizeTest();
        }
      }
    });
  }

  void _nextQuestion(String? answer, {bool skipped = false}) async {
    // すでにテストが完了している場合は何もしない
    if (_isTestCompleted) {
      return;
    }

    _questionTimer?.cancel();
    _timerAnimationController.stop();

    if (!skipped && answer != null) {
      _userAnswers.add(answer);
      _processAnswer(answer);
    }

    _textController.clear();

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _startQuestionTimer();
      } else {
        // テストを最終確定
        _finalizeTest();
      }
    });
  }

  void _finalizeTest() {
    // 複数回呼び出されないように保護
    if (_isTestCompleted) return;

    _isTestCompleted = true;
    _questionTimer?.cancel();

    // モーダルが既に表示されていないことを確認
    if (!_isDialogShowing) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    // ダイアログが既に表示されている場合は何もしない
    if (_isDialogShowing || !_isTestCompleted) {
      return;
    }

    _isDialogShowing = true;

    final resultComment = _getResultInterpretation();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('認知機能テスト結果'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('スコア: $_score',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  resultComment,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // ダイアログ表示状態をリセット
                  _isDialogShowing = false;
                  _finishTest();
                },
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getResultInterpretation() {
    if (_score >= 10) {
      return '認知機能は正常範囲内です。';
    } else if (_score >= 8) {
      return '軽度の認知機能低下が疑われます。\n医療専門家に相談することをお勧めします。';
    } else if (_score >= 6) {
      return '中等度の認知機能低下が疑われます。\n早めに医療専門家に相談してください。';
    } else if (_score >= 4) {
      return '高度の認知機能低下が疑われます。\n至急、医療専門家に相談してください。';
    } else {
      return '非常に高度の認知機能低下が疑われます。\n直ちに医療専門家に相談してください。';
    }
  }

  Widget _buildQuestionInput() {
    final question = _questions[_currentQuestionIndex];
    switch (question['type']) {
      case 'image_memory':
        return _ImageMemoryTestWidget(
          images: question['images'] ?? [],
          multipleChoiceQuestions: question['multipleChoiceQuestions'] ?? [],
          onSubmit: _nextQuestion,
          onSelectionScreenReady: () {
            // タイマーを自動開始
            _remainingTime = question['timeLimit'];
            _timerAnimationController.reset();
            _timerAnimationController.forward();

            _questionTimer?.cancel();
            _questionTimer =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                _remainingTime--;
              });

              if (_remainingTime <= 0) {
                _questionTimer?.cancel();
                _nextQuestion(null);
              }
            });
          },
        );

      case 'memory_stage1':
      case 'reverse_number_memory':
      case 'number_recall':
        return _MemoryTestWidget(
          memorizedWords: question['type'] == 'memory_stage1'
              ? (question['memorizedWords'] ?? [])
              : (question['type'] == 'reverse_number_memory'
                  ? (question['memorizedWords'] ?? [])
                  : []),
          multipleChoiceQuestions: question['multipleChoiceQuestions'] ?? [],
          onSubmit: _nextQuestion,
          initialStage: _currentQuestionIndex == 6 ? 2 : 0,
          onSelectionScreenReady: () {
            // number_recallの場合はタイマーを自動開始
            _remainingTime = question['timeLimit'];
            _timerAnimationController.reset();
            _timerAnimationController.forward();

            _questionTimer?.cancel();
            _questionTimer =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                _remainingTime--;
              });

              if (_remainingTime <= 0) {
                _questionTimer?.cancel();
                _nextQuestion(null);
              }
            });
          },
        );

      case 'math_stage1':
        return Column(
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: question['options']
                  .map<Widget>((option) => ElevatedButton(
                        onPressed: () => _nextQuestion(option),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ],
        );

      case 'location_description':
        return Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '今いる場所を具体的に教えてください',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _nextQuestion(_textController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: const Text(
                '回答を送信する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

      case 'detailed_date':
        return _DetailedDateInput(
          options: question['options'],
          onSubmit: _nextQuestion,
        );

      case 'age':
        return Column(
          children: [
            TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'あなたの年齢を入力してください（半角数字）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _nextQuestion(_textController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: const Text(
                '回答を送信する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ...question['options']
                    .map<Widget>((option) => ElevatedButton(
                          onPressed: () => _nextQuestion(option),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                ElevatedButton(
                  onPressed: () => _nextQuestion('わからない'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'わからない',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
      case 'vegetable_list':
        return _VegetableListWidget(
          onSubmit: _nextQuestion,
          timeLimit: _questions[_currentQuestionIndex]['timeLimit'],
        );

      default:
        return Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: question['type'] == 'birthday'
                    ? '例: 1980年1月1日'
                    : '例: ${DateFormat('HH:mm').format(DateTime.now())}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _nextQuestion(_textController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: const Text(
                '回答を送信する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
    }
  }

  void _finishTest() async {
    int score = _calculateScore();
    String comment = _generateComment(score);

    Get.to(() => HomeScreen(), arguments: {
      'initialTestResult': {
        'score': score,
        'comment': comment,
      },
    });
  }

  // スコアを計算するメソッド
  int _calculateScore() {
    return _score; // すでに各問題で_scoreを加算しているため、そのまま返す
  }

  // スコアに基づいてコメントを生成
  String _generateComment(int score) {
    if (score >= 21) {
      return '認知機能は正常範囲内です。現在の生活習慣を継続してください。';
    } else if (score >= 16) {
      return '軽度の認知機能低下の可能性があります。生活習慣の改善と定期的な健康チェックをお勧めします。';
    } else if (score >= 11) {
      return '中等度の認知機能低下が疑われます。医療専門家に相談し、早期対応が重要です。';
    } else if (score >= 5) {
      return '高度の認知機能低下が疑われます。専門的な医療支援が必要です。';
    } else {
      return '非常に高度の認知機能低下が疑われます。早急に専門医の診察を受けることを強くお勧めします。';
    }
  }

  // 曜日を日本語文字列に変換するヘルパーメソッド
  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return '月曜日';
      case 2:
        return '火曜日';
      case 3:
        return '水曜日';
      case 4:
        return '木曜日';
      case 5:
        return '金曜日';
      case 6:
        return '土曜日';
      case 7:
        return '日曜日';
      default:
        return '';
    }
  }

  // テスト説明用のダイアログを表示するメソッド
  void _showTestInstructionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '認知機能テストについて',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text(
                  'このテストは、認知機能の現状を評価するためのものです。以下の点に注意してください：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildInstructionPoint(
                  '目的',
                  '記憶力、注意力、計算能力などの認知機能を総合的に評価します。',
                ),
                _buildInstructionPoint(
                  '所要時間',
                  '全${_questions.length}問で、各問題の制限時間は30秒です。',
                ),
                _buildInstructionPoint(
                  '注意事項',
                  '落ち着いて、できる範囲で回答してください。分からない場合は「わからない」を選択できます。',
                ),
                _buildInstructionPoint(
                  '結果の解釈',
                  '結果は参考情報です。医療専門家に相談することをお勧めします。',
                ),
                const SizedBox(height: 10),
                const Text(
                  '準備ができましたら、「テストを開始」ボタンを押してください。',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // モーダルを閉じた後にタイマーを再開
                _startQuestionTimer();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: const Text(
                'テストを開始',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // 説明ポイントを構築するヘルパーメソッド
  Widget _buildInstructionPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }

  // 採点ロジックを別メソッドに分離
  void _processAnswer(String answer) async {
    switch (_questions[_currentQuestionIndex]['type']) {
      case 'reverse_number_memory':
        try {
          // 回答を解析
          final selectedAnswers = answer.split('|');
          final multipleChoiceQuestions =
              _questions[_currentQuestionIndex]['multipleChoiceQuestions'];

          // 各多肢選択問題で正解を選んだら1点
          for (var i = 0; i < multipleChoiceQuestions.length; i++) {
            if (selectedAnswers[i] ==
                multipleChoiceQuestions[i]['correctAnswer']) {
              _score++;
            }
          }
        } catch (e) {}
        break;

      case 'math_stage1':
        // 問題で正解を選んだら1点
        if (answer == _questions[_currentQuestionIndex]['correctAnswer']) {
          _score++;
        }

        // 次のステージがある場合は進む
        if (_questions[_currentQuestionIndex].containsKey('nextStage')) {
          setState(() {
            // 現在の質問のnextStageを次の質問として挿入
            _questions.insert(_currentQuestionIndex + 1,
                _questions[_currentQuestionIndex]['nextStage']);
            _currentQuestionIndex++;
            _startQuestionTimer();
          });
          return;
        }
        break;

      case 'memory_stage1':
        try {
          // 回答を解析
          final selectedAnswers = answer.split('|');
          final multipleChoiceQuestions =
              _questions[_currentQuestionIndex]['multipleChoiceQuestions'];

          // 各多肢選択問題で正解を選んだら1点
          for (var i = 0; i < multipleChoiceQuestions.length; i++) {
            if (selectedAnswers[i] ==
                multipleChoiceQuestions[i]['correctAnswer']) {
              _score++;
            }
          }
        } catch (e) {}
        break;

      case 'location_description':
        // 自発的で具体的な回答であれば2点
        if (answer.trim().isNotEmpty && answer.length > 2) {
          _score += 2;
        }
        break;

      case 'detailed_date':
        try {
          // 正解の日付を取得
          final correctDate =
              _questions[_currentQuestionIndex]['correctAnswer'];

          // 入力された値を解析
          final parts = answer.split('|');
          if (parts.length == 4) {
            // 年、月、日、曜日それぞれ1点
            if (parts[0] == correctDate['year']) _score++;
            if (parts[1] == correctDate['month']) _score++;
            if (parts[2] == correctDate['day']) _score++;
            if (parts[3] == correctDate['weekday']) _score++;
          }
        } catch (e) {}
        break;

      case 'age':
        try {
          // ユーザーの年齢を取得
          User user = await _apiService.fetchUserProfile('dummy_user_id');
          int userAge = user.age;
          int answeredAge = int.parse(answer);

          // 誤差2年以内であれば1点
          if ((userAge - answeredAge).abs() <= 2) {
            _score++;
          }
        } catch (e) {}
        break;

      case 'date':
        if (answer == _questions[_currentQuestionIndex]['correctAnswer']) {
          _score++;
        }
        break;
      case 'season':
      case 'animal':
      case 'recall':
        if (_questions[_currentQuestionIndex]['options'].contains(answer)) {
          _score++;
        }
        break;
      case 'image_memory':
        try {
          // 回答を解析
          final selectedAnswers = answer.split('|');
          final multipleChoiceQuestions =
              _questions[_currentQuestionIndex]['multipleChoiceQuestions'];

          // 各多肢選択問題で正解を選んだら1点
          for (var i = 0; i < multipleChoiceQuestions.length; i++) {
            if (selectedAnswers[i] ==
                multipleChoiceQuestions[i]['correctAnswer']) {
              _score++;
            }
          }
        } catch (e) {}
        break;
      case 'vegetable_list':
        try {
          // 入力された野菜のリストを解析
          final List<String> vegetables = answer.split(',');
          // 野菜の数を点数として加算
          _score += vegetables.length;
        } catch (e) {}
        break;
      // 他の質問タイプの採点ロジック
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '認知機能テスト',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => _nextQuestion(null, skipped: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'スキップ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _timerAnimation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingTime <= 10 ? Colors.red : Colors.blue,
                      ),
                      minHeight: 10,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentQuestionIndex + 1}問目 / 全${_questions.length}問',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  '残り時間: $_remainingTime 秒',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _remainingTime <= 10 ? Colors.red : Colors.black,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildQuestionInput(),
          ],
        ),
      ),
    );
  }
}

class _DetailedDateInput extends StatefulWidget {
  final Map<String, List<String>?> options;
  final Function(String?) onSubmit;

  const _DetailedDateInput(
      {Key? key, required this.options, required this.onSubmit})
      : super(key: key);

  @override
  State<_DetailedDateInput> createState() => _DetailedDateInputState();
}

class _DetailedDateInputState extends State<_DetailedDateInput> {
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;
  String? selectedWeekday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            // 年のドロップダウン
            Container(
              width: 100,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '年',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('年'),
                value: selectedYear,
                items: widget.options['years']
                        ?.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList() ??
                    [],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
              ),
            ),

            // 月のドロップダウン
            Container(
              width: 80,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '月',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('月'),
                value: selectedMonth,
                items: widget.options['months']
                        ?.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList() ??
                    [],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                },
              ),
            ),

            // 日のドロップダウン
            Container(
              width: 80,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '日',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('日'),
                value: selectedDay,
                items: widget.options['days']
                        ?.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList() ??
                    [],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDay = newValue;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 曜日のラジオボタン
        Text(
          '曜日を選択してください',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: widget.options['weekdays']?.map<Widget>((String weekday) {
                return ChoiceChip(
                  label: Text(weekday),
                  selected: selectedWeekday == weekday,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedWeekday = selected ? weekday : null;
                    });
                  },
                  selectedColor: Colors.blue[200],
                );
              }).toList() ??
              [],
        ),

        const SizedBox(height: 20),

        // 送信ボタン
        ElevatedButton(
          onPressed: selectedYear != null &&
                  selectedMonth != null &&
                  selectedDay != null &&
                  selectedWeekday != null
              ? () {
                  // 選択された値を | で結合して送信
                  final answer =
                      '$selectedYear|$selectedMonth|$selectedDay|$selectedWeekday';
                  widget.onSubmit(answer);
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue[600],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          child: const Text(
            '回答を送信する',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _MemoryTestWidget extends StatefulWidget {
  final List<String> memorizedWords;
  final List<Map<String, dynamic>> multipleChoiceQuestions;
  final Function(String?) onSubmit;
  final int initialStage;
  final VoidCallback? onSelectionScreenReady;

  const _MemoryTestWidget({
    Key? key,
    required this.memorizedWords,
    required this.multipleChoiceQuestions,
    required this.onSubmit,
    required this.initialStage,
    this.onSelectionScreenReady,
  }) : super(key: key);

  @override
  State<_MemoryTestWidget> createState() => _MemoryTestWidgetState();
}

class _MemoryTestWidgetState extends State<_MemoryTestWidget> {
  int _stage = 0; // 0: カウントダウン, 1: フラッシュ表示, 2: 選択画面
  int _flashIndex = 0;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;

    if (_stage == 0) {
      _startCountdown();
    } else if (_stage == 2) {
      // 選択画面の場合はすぐにonSelectionScreenReadyを呼び出す
      widget.onSelectionScreenReady?.call();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _stage = 0;
    _countdownSeconds = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _startFlashWords();
      }
    });
  }

  void _startFlashWords() {
    _stage = 1;
    _flashIndex = 0;
    _flashTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _flashIndex++;
      });

      if (_flashIndex >= widget.memorizedWords.length) {
        timer.cancel();
        _showMultipleChoiceQuestions();
      }
    });
  }

  void _showMultipleChoiceQuestions() {
    setState(() {
      _stage = 2;
    });

    // タイマー開始のコールバックを呼び出す
    widget.onSelectionScreenReady?.call();
  }

  List<List<String>> selectedAnswers = [];

  @override
  Widget build(BuildContext context) {
    if (_stage == 0) {
      // カウントダウン画面
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_countdownSeconds',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (_stage == 1) {
      // フラッシュ表示画面
      return Center(
        child: Text(
          widget.memorizedWords[_flashIndex],
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
    }

    // 選択画面
    return Column(
      children: [
        ...List.generate(widget.multipleChoiceQuestions.length, (index) {
          final question = widget.multipleChoiceQuestions[index];

          // 各質問の選択状態を管理するリストを初期化
          if (selectedAnswers.length <= index) {
            selectedAnswers.add([]);
          }

          return Column(
            children: [
              Text(question['question']),
              ...question['options']
                  .map<Widget>((option) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // 同じ質問の他の選択肢をクリア
                            selectedAnswers[index] = [option];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedAnswers[index].contains(option)
                                  ? Colors.green
                                  : null,
                        ),
                        child: Text(option),
                      ))
                  .toList(),
            ],
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              selectedAnswers.length == widget.multipleChoiceQuestions.length &&
                      selectedAnswers.every((answers) => answers.isNotEmpty)
                  ? () {
                      // 選択された回答を送信
                      widget.onSubmit(selectedAnswers
                          .map((answers) => answers.first)
                          .join('|'));
                    }
                  : null,
          child: const Text('回答する'),
        ),
      ],
    );
  }
}

class _ImageMemoryTestWidget extends StatefulWidget {
  final List<String> images;
  final List<Map<String, dynamic>> multipleChoiceQuestions;
  final Function(String?) onSubmit;
  final VoidCallback onSelectionScreenReady;

  const _ImageMemoryTestWidget({
    Key? key,
    required this.images,
    required this.multipleChoiceQuestions,
    required this.onSubmit,
    required this.onSelectionScreenReady,
  }) : super(key: key);

  @override
  State<_ImageMemoryTestWidget> createState() => _ImageMemoryTestWidgetState();
}

class _ImageMemoryTestWidgetState extends State<_ImageMemoryTestWidget> {
  int _stage = 0; // 0: カウントダウン, 1: フラッシュ表示, 2: 選択画面
  int _flashIndex = 0;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _stage = 0;

    if (_stage == 0) {
      _startCountdown();
    } else if (_stage == 2) {
      // 選択画面の場合はすぐにonSelectionScreenReadyを呼び出す
      widget.onSelectionScreenReady();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _stage = 0;
    _countdownSeconds = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _startFlashWords();
      }
    });
  }

  void _startFlashWords() {
    _stage = 1;
    _flashIndex = 0;
    _flashTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _flashIndex++;
      });

      if (_flashIndex >= widget.images.length) {
        timer.cancel();
        _showMultipleChoiceQuestions();
      }
    });
  }

  void _showMultipleChoiceQuestions() {
    setState(() {
      _stage = 2;
    });

    // タイマー開始のコールバックを呼び出す
    widget.onSelectionScreenReady();
  }

  List<List<String>> selectedAnswers = [];

  @override
  Widget build(BuildContext context) {
    if (_stage == 0) {
      // カウントダウン画面
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_countdownSeconds',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (_stage == 1) {
      // フラッシュ表示画面
      return Center(
        child: Image.asset(
          widget.images[_flashIndex],
          width: 200,
          height: 200,
        ),
      );
    }

    // 選択画面
    return Column(
      children: [
        ...List.generate(widget.multipleChoiceQuestions.length, (index) {
          final question = widget.multipleChoiceQuestions[index];

          // 各質問の選択状態を管理するリストを初期化
          if (selectedAnswers.length <= index) {
            selectedAnswers.add([]);
          }

          return Column(
            children: [
              Text(question['question']),
              ...question['options']
                  .map<Widget>((option) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // 同じ質問の他の選択肢をクリア
                            selectedAnswers[index] = [option];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedAnswers[index].contains(option)
                                  ? Colors.green
                                  : null,
                        ),
                        child: Text(option),
                      ))
                  .toList(),
            ],
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              selectedAnswers.length == widget.multipleChoiceQuestions.length &&
                      selectedAnswers.every((answers) => answers.isNotEmpty)
                  ? () {
                      // 選択された回答を送信
                      widget.onSubmit(selectedAnswers
                          .map((answers) => answers.first)
                          .join('|'));
                    }
                  : null,
          child: const Text('回答する'),
        ),
      ],
    );
  }
}

class _VegetableListWidget extends StatefulWidget {
  final Function(String?) onSubmit;
  final int? timeLimit;

  const _VegetableListWidget({
    Key? key,
    required this.onSubmit,
    this.timeLimit,
  }) : super(key: key);

  @override
  State<_VegetableListWidget> createState() => _VegetableListWidgetState();
}

class _VegetableListWidgetState extends State<_VegetableListWidget> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _vegetables = [];
  final Set<String> _uniqueVegetables = {};
  int _remainingTime = 0;
  Timer? _questionTimer;

  @override
  void initState() {
    super.initState();
    // タイマーがある場合のみ開始
    if (widget.timeLimit != null) {
      _remainingTime = widget.timeLimit!;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        timer.cancel();
        // 制限時間が過ぎたら自動的に回答を送信
        widget.onSubmit(_vegetables.join(','));
      }
    });
  }

  void _addVegetable(String vegetable) {
    if (vegetable.trim().isNotEmpty && !_uniqueVegetables.contains(vegetable)) {
      setState(() {
        _vegetables.add(vegetable);
        _uniqueVegetables.add(vegetable);
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // タイマーがある場合のみ表示
        if (widget.timeLimit != null)
          Text(
            '残り時間: $_remainingTime 秒',
            style: TextStyle(
              color: _remainingTime <= 10 ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: '野菜の名前を入力してください',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _addVegetable(_textController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: const Text('追加'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_vegetables.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vegetables.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_vegetables[index]),
                trailing: Text(
                  '${index + 1}点',
                  style: const TextStyle(color: Colors.green),
                ),
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _vegetables.isNotEmpty
                ? () {
                    // 入力された野菜のリストをカンマ区切りで送信
                    _questionTimer?.cancel();
                    widget.onSubmit(_vegetables.join(','));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            child: const Text(
              '回答終了',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

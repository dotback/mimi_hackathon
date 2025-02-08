import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../data/models/problem.dart';
import '../services/speech_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LanguageProblemScreen extends StatefulWidget {
  final Problem problem;

  const LanguageProblemScreen({Key? key, required this.problem})
      : super(key: key);

  @override
  _LanguageProblemScreenState createState() => _LanguageProblemScreenState();
}

class _LanguageProblemScreenState extends State<LanguageProblemScreen>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  final String apiKey = Get.find(tag: 'geminiApiKey');
  late SpeechService _speechService;
  late GenerativeModel _generativeModel;
  late AnimationController _micAnimationController;
  late Animation<double> _micAnimation;

  bool _isAISpeaking = false;
  bool _isListening = false;
  bool _isSubmitted = false;
  bool _isSpeaking = false;
  Timer? _descriptionTimer;
  Timer? _countdownTimer;
  int _remainingDescriptionSeconds = 5;
  int _remainingSeconds = 30;
  String _recognizedText = '';
  bool _isAnalyzing = false;
  AnswerEvaluation? _evaluation;
  List<String> _recognizedTextHistory = [];
  String _currentRecognizedText = '';
  bool _isEvaluationInProgress = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // マイクアニメーション用のコントローラーとアニメーション
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _micAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _micAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    try {
      _speechService = SpeechService(apiKey);
      _generativeModel =
          GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

      // 問題文の読み上げを自動開始
      _startProblemDescription();
    } catch (e, stackTrace) {
      developer.log(
        'LanguageProblemScreen初期化エラー',
        error: e,
        stackTrace: stackTrace,
      );
      _showErrorDialog(e.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // アプリがバックグラウンドに移行した場合のリソース解放
      _stopAllProcesses();
    }
  }

  void _stopAllProcesses() {
    _countdownTimer?.cancel();
    _speechService.dispose();
  }

  void _startProblemDescription() async {
    setState(() {
      _isAISpeaking = true;
    });

    // 問題文を音声で読み上げ
    await _speechService.speak(widget.problem.description);

    // 問題文読み上げ用のタイマーを開始
    _startDescriptionCountdown();
  }

  void _startDescriptionCountdown() {
    _descriptionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingDescriptionSeconds--;
      });

      if (_remainingDescriptionSeconds <= 0) {
        timer.cancel();
        _startListeningPhase();
      }
    });
  }

  void _startListeningPhase() {
    setState(() {
      _isAISpeaking = false;
      _isListening = true;
    });

    // 音声入力の30秒タイマーを開始
    _startCountdown();
    _startSpeechRecognition();
  }

  void _startCountdown() {
    // カウントダウンタイマーをキャンセル
    _countdownTimer?.cancel();

    // 初期値を30に設定
    _remainingSeconds = 30;

    // タイマーを1秒ごとに更新
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // マウントされていない場合はタイマーをキャンセル
      if (!mounted) {
        timer.cancel();
        return;
      }

      // UIスレッドで安全に更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      });

      // 残り時間が0になったら処理
      if (_remainingSeconds <= 0) {
        timer.cancel();

        // タイムアウト時の処理
        _speechService.dispose();

        // UIの更新
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _isAnalyzing = true;
              _micAnimationController.stop();
              _micAnimationController.reset();
            });

            // 回答の検証
            _validateAnswer();
          }
        });
      }
    });
  }

  void _startSpeechRecognition() async {
    try {
      // すでに評価中の場合は処理を中断
      if (_isEvaluationInProgress) {
        print('評価プロセスは既に進行中です');
        return;
      }

      // カウントダウンタイマーをキャンセル
      _countdownTimer?.cancel();

      // 音声認識履歴と現在の認識テキストをクリア
      _recognizedTextHistory.clear();
      _currentRecognizedText = '';
      _recognizedText = ''; // 明示的に空文字列に設定
      _evaluation = null; // 評価をリセット

      // 音声認識を開始
      setState(() {
        _isListening = true;
        _isAnalyzing = false;
        _isSubmitted = false;
        _remainingSeconds = 30; // 初期値を明示的にリセット
      });

      // カウントダウンを開始
      _startCountdown();

      // 音声認識の結果を待機
      final recognizedText = await _speechService.listen(
        onSpeechStart: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isListening = true;
                _micAnimationController.repeat(reverse: true);
              });
            }
          });
        },
        onSpeechEnd: () {
          _countdownTimer?.cancel();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isListening = false;
                _isAnalyzing = true;
                _micAnimationController.stop();
                _micAnimationController.reset();
              });
            }
          });
        },
        // 部分的な結果を受け取るコールバックを追加
        onPartialResult: (partialText) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                // 現在の認識テキストを更新（上書き）
                _currentRecognizedText = partialText;

                // 部分的な結果も_recognizedTextに追加
                if (_recognizedText.isEmpty) {
                  _recognizedText = partialText;
                } else {
                  _recognizedText += ' ' + partialText;
                }

                print('部分的な認識テキスト: $_recognizedText');
              });
            }
          });
        },
        timeout: Duration(seconds: 30),
      );

      // 認識されたテキストを処理
      if (recognizedText == null) {
        _countdownTimer?.cancel();

        // エラーダイアログを表示し、適切に画面遷移
        _showErrorDialog('音声の文字起こしに失敗しました。\n'
            '考えられる原因:\n'
            '- 音声が不明瞭です\n'
            '- 音声認識サービスに接続できません\n'
            '- ネットワーク接続を確認してください');

        return;
      }

      // 認識されたテキストを保存
      _recognizedText = recognizedText;
      developer.log('認識されたテキストを設定: $_recognizedText',
          name: 'SpeechRecognition');

      // 回答の正誤判定を実施（音声認識の最後のみで実行）
      try {
        // 評価プロセスのフラグを設定
        _isEvaluationInProgress = true;
        await _validateAnswer();
      } finally {
        // 評価プロセスのフラグをリセット
        _isEvaluationInProgress = false;
      }
    } catch (e, stackTrace) {
      _countdownTimer?.cancel();
      developer.log(
        '音声認識プロセスエラー',
        error: e,
        stackTrace: stackTrace,
      );

      // より詳細なエラーメッセージ
      _showErrorDialog('予期せぬエラーが発生しました。\n'
          'エラー詳細: ${e.toString()}\n'
          'デバイスの設定と接続を確認してください。');
    }
  }

  void _stopSpeechRecognition() {
    _countdownTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    // 回答の正誤判定を削除（重複を防ぐ）
  }

  Future<void> _validateAnswer() async {
    // すでに評価済みの場合は処理しない
    if (_evaluation != null) return;

    try {
      // デバッグログを追加
      print('_validateAnswer() メソッド開始');
      print('認識されたテキスト: $_recognizedText');
      print('現在の認識テキスト: $_currentRecognizedText');

      // 空の回答を防ぐ
      String finalText =
          _recognizedText.isNotEmpty ? _recognizedText : _currentRecognizedText;

      if (finalText.trim().isEmpty) {
        // 音声認識が完了するまで待機
        await Future.delayed(Duration(seconds: 2));

        // 再度テキストをチェック
        finalText = _recognizedText.isNotEmpty
            ? _recognizedText
            : _currentRecognizedText;

        if (finalText.trim().isEmpty) {
          print('音声認識が完了していません。再試行します。');
          return;
        }
      }

      // デバッグログを追加
      print('最終的に使用するテキスト: $finalText');

      // 解析中フラグをセット
      setState(() {
        _isListening = false;
        _isAnalyzing = true;
      });

      // タイムアウトを設定
      final timeoutDuration = Duration(seconds: 70);
      final evaluationFuture =
          _speechService.evaluateAnswer(widget.problem.description, finalText);

      final evaluation = await evaluationFuture.timeout(
        timeoutDuration,
        onTimeout: () {
          developer.log(
            '回答検証がタイムアウトしました',
            name: 'AnswerValidation',
          );
          throw TimeoutException('回答の検証に時間がかかりすぎています');
        },
      );

      // デバッグログを追加
      print('評価結果の詳細:');
      print('isCorrect: ${evaluation.isCorrect}');
      print('result: ${evaluation.result}');
      print('improvements: ${evaluation.improvements}');
      print('explanation: ${evaluation.explanation}');

      if (!mounted) {
        print('ウィジェットがマウントされていません');
        return;
      }

      // UIスレッドで状態を更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isSubmitted = true;
            _isAnalyzing = false;
            _isListening = false;

            // userAnswerを明示的に設定
            _evaluation = evaluation.copyWith(userAnswer: finalText);

            // デバッグ用のprint
            print('状態更新完了');
            print('_evaluation: $_evaluation');
          });
        } else {
          print('マウント後のコールバックでもウィジェットがマウントされていません');
        }
      });
    } catch (e, stackTrace) {
      print('_validateAnswer() エラー発生');
      developer.log(
        '回答検証エラー',
        error: e,
        stackTrace: stackTrace,
      );

      // エラーダイアログを表示し、適切に画面遷移
      _showErrorDialog('回答の検証中にエラーが発生しました：${e.toString()}');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('エラーが発生しました'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              // ダイアログを閉じる
              Navigator.of(context).pop();

              // 音声認識と分析の状態をリセット
              setState(() {
                _isListening = false;
                _isAnalyzing = false;
                _micAnimationController.stop();
                _micAnimationController.reset();
              });

              // 前の画面に戻る
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _descriptionTimer?.cancel();
    _countdownTimer?.cancel();
    _speechService.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.problem.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 問題説明カード
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.problem.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 動的セクション
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _getCurrentSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCurrentSection() {
    print('_getCurrentSection() 呼び出し');
    print('_isAISpeaking: $_isAISpeaking');
    print('_isListening: $_isListening');
    print('_isAnalyzing: $_isAnalyzing');
    print('_evaluation: $_evaluation');

    if (_isAISpeaking) return _buildAISpeakingSection();
    if (_isListening) return _buildListeningSection();
    if (_isAnalyzing) return _buildAnalyzingSection();
    if (_evaluation != null) {
      print('結果セクションを表示');
      return _buildResultSection();
    }
    print('空のセクションを表示');
    return SizedBox.shrink();
  }

  Widget _buildAISpeakingSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.waveDots(
            color: Colors.blue.shade600,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'AIが問題を読み上げています...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '開始まで: $_remainingDescriptionSeconds 秒',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '質問に回答してください',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Text(
            '30秒間、音声で回答します',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '残り時間: $_remainingSeconds 秒',
            style: TextStyle(
              fontSize: 18,
              color:
                  _remainingSeconds <= 10 ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '話し終えたら、自動的に解析が始まります',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ScaleTransition(
            scale: _micAnimation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.white,
                ),
                onPressed: _startSpeechRecognition,
              ),
            ),
          ),
          if (_currentRecognizedText.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _currentRecognizedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.blue.shade600,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'Gemini AIが回答を解析中...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '音声を文字に起こし、AIが評価しています',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    // _evaluationがnullでないことを再確認
    if (_evaluation == null) {
      print('_evaluationがnullです。結果セクションを表示できません。');
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル
            Text(
              '評価結果',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // 結果カード
            _buildDetailCard(
              title: '結果',
              content: _evaluation!.result,
              color: _evaluation!.isCorrect
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              icon: _evaluation!.isCorrect
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              iconColor: _evaluation!.isCorrect ? Colors.green : Colors.red,
            ),

            SizedBox(height: 16),

            // ユーザー回答カード
            _buildDetailCard(
              title: 'あなたの回答',
              content: _evaluation!.userAnswer,
              color: Colors.grey.shade100,
              icon: Icons.record_voice_over,
              iconColor: Colors.blue,
            ),

            SizedBox(height: 16),

            // 改善点カード
            _buildDetailCard(
              title: '改善点',
              content: _evaluation!.improvements,
              color: Colors.blue.shade50,
              icon: Icons.lightbulb_outline,
              iconColor: Colors.orange,
            ),

            SizedBox(height: 16),

            // 詳細説明カード
            _buildDetailCard(
              title: '詳細な説明',
              content: _evaluation!.explanation,
              color: Colors.purple.shade50,
              icon: Icons.info_outline,
              iconColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // 詳細カードのカスタムウィジェット
  Widget _buildDetailCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル行
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // コンテンツ
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

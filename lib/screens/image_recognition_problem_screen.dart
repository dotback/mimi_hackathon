import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/problem.dart';
import '../services/image_recognition_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// 画面の状態を管理する列挙型
enum ScreenState {
  imageSelection,
  problemGeneration,
  answerSubmission,
  resultDisplay
}

class ImageRecognitionProblemScreen extends StatefulWidget {
  final Problem problem;

  const ImageRecognitionProblemScreen({Key? key, required this.problem})
      : super(key: key);

  @override
  _ImageRecognitionProblemScreenState createState() =>
      _ImageRecognitionProblemScreenState();
}

class _ImageRecognitionProblemScreenState
    extends State<ImageRecognitionProblemScreen> {
  final String apiKey = Get.find(tag: 'geminiApiKey');
  late ImageRecognitionService _imageRecognitionService;

  // 事前に用意された画像のリスト
  final List<String> _predefinedImages = [
    'assets/question_images/1000002275.jpg',
    'assets/question_images/1000002209.jpg',
    'assets/question_images/1000002171.jpg',
    'assets/question_images/1000001815.jpg',
    'assets/question_images/1000001375.jpg',
    'assets/question_images/1000001412.jpg',
    'assets/question_images/1000001442.jpg',
    'assets/question_images/1000001160.jpg',
    'assets/question_images/1000000891.jpg',
    'assets/question_images/1000001320.jpg',
    'assets/question_images/1000000832.jpg',
    'assets/question_images/1000000191.jpg',
    'assets/question_images/1000000134.jpg',
    'assets/question_images/1000002288.jpg',
  ];

  String? _selectedImage;
  ScreenState _currentState = ScreenState.imageSelection;
  bool _isProcessing = false;
  Map<String, dynamic>? _problemDetails;
  Map<String, dynamic>? _evaluationResult;

  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageRecognitionService = ImageRecognitionService(apiKey);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _selectImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('画像の確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text('この画像で問題を生成しますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedImage = imagePath;
                _currentState = ScreenState.problemGeneration;
                _problemDetails = null;
                _evaluationResult = null;
                _answerController.clear();
              });
            },
            child: Text('はい'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result =
          await _imageRecognitionService.generateImageProblem(_selectedImage!);

      setState(() {
        _problemDetails = result;
        _isProcessing = false;
        _currentState = ScreenState.answerSubmission;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedImage == null || _problemDetails == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _imageRecognitionService.evaluateAnswer(
        imagePath: _selectedImage!,
        problem: _problemDetails!['problem'],
        correctAnswer: _problemDetails!['correctAnswer'],
        userAnswer: _answerController.text.trim(),
      );

      setState(() {
        _evaluationResult = result;
        _currentState = ScreenState.resultDisplay;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _resetScreen() {
    setState(() {
      _selectedImage = null;
      _currentState = ScreenState.imageSelection;
      _problemDetails = null;
      _evaluationResult = null;
      _answerController.clear();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('画像認識問題'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentState != ScreenState.imageSelection)
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: _resetScreen,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 問題説明
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.problem.description,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 画像選択状態
              if (_currentState == ScreenState.imageSelection)
                Column(
                  children: [
                    Text(
                      '画像を選択してください',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _predefinedImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _selectImage(_predefinedImages[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _selectedImage == _predefinedImages[index]
                                        ? Colors.blue
                                        : Colors.grey,
                                width:
                                    _selectedImage == _predefinedImages[index]
                                        ? 3
                                        : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              _predefinedImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

              // 問題生成状態
              if (_currentState == ScreenState.problemGeneration)
                Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Image.asset(
                        _selectedImage!,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _processImage,
                      child: Text('問題を生成'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),

              // 回答入力状態
              if (_currentState == ScreenState.answerSubmission)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      child: Image.asset(
                        _selectedImage!,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '問題',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _problemDetails!['problem'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        hintText: '回答を入力してください',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitAnswer,
                      child: Text('回答を提出'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),

              // 結果表示状態
              if (_currentState == ScreenState.resultDisplay)
                _buildResultSection(),

              // 処理中インジケーター
              if (_isProcessing)
                Center(
                  child: Column(
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.blue,
                        size: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _currentState == ScreenState.problemGeneration
                            ? 'Gemini AIが問題を生成しています...'
                            : 'Gemini AIが回答を確認しています...',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ユーザーの回答カード
        _buildDetailCard(
          title: 'あなたの回答',
          content: _evaluationResult!['userAnswer'],
          color: Colors.grey.shade100,
          icon: Icons.chat_outlined,
          iconColor: Colors.grey,
        ),

        SizedBox(height: 16),

        // 正誤カード
        _buildDetailCard(
          title: '評価結果',
          content: _evaluationResult!['result'],
          color: _evaluationResult!['isCorrect']
              ? Colors.green.shade50
              : Colors.orange.shade50,
          icon: _evaluationResult!['isCorrect']
              ? Icons.check_circle_outline
              : Icons.lightbulb_outline,
          iconColor:
              _evaluationResult!['isCorrect'] ? Colors.green : Colors.orange,
        ),

        SizedBox(height: 16),

        // 説明カード
        _buildDetailCard(
          title: '回答分析',
          content: _evaluationResult!['explanation'],
          color: Colors.blue.shade50,
          icon: Icons.psychology_outlined,
          iconColor: Colors.blue,
        ),

        SizedBox(height: 16),

        // 改善点カード
        _buildDetailCard(
          title: '学習のヒント',
          content: _evaluationResult!['improvements'],
          color: Colors.purple.shade50,
          icon: Icons.tips_and_updates_outlined,
          iconColor: Colors.purple,
        ),

        SizedBox(height: 16),

        // 正解カード
        _buildDetailCard(
          title: '正解',
          content: _problemDetails!['correctAnswer'],
          color: Colors.amber.shade50,
          icon: Icons.stars_outlined,
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
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
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

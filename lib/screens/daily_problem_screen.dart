import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../data/models/problem_result.dart';
import '../data/models/problem.dart';
import '../logic/services/problem_service.dart';
import 'problem_solve_screen.dart';
import 'language_problem_screen.dart';
import 'image_recognition_problem_screen.dart';
import 'package:get/get.dart';

class DailyProblemScreen extends StatefulWidget {
  final Map<String, dynamic>? personalizedTest;

  const DailyProblemScreen({
    super.key,
    this.personalizedTest,
  });

  @override
  State<DailyProblemScreen> createState() => _DailyProblemScreenState();
}

class _DailyProblemScreenState extends State<DailyProblemScreen> {
  final ProblemService _problemService = ProblemService();
  late Future<List<Problem>> _dailyProblems;
  late Future<List<ProblemResult>> _problemResultTrends;

  // モックデータ
  final int _mockTodaysScore = 85;
  final String _mockEncouragementMessage = '素晴らしい進歩です！継続は力なり！';
  final Map<ProblemCategory, double> _mockCategoryPerformance = {
    ProblemCategory.memory: 0.85,
    ProblemCategory.recall: 0.72,
    ProblemCategory.calculation: 0.65,
    ProblemCategory.language: 0.90,
    ProblemCategory.orientation: 0.78,
  };

  // 点数の推移のモックデータ
  final List<ProblemResult> _mockProblemResultTrends = [
    ProblemResult(
      problemId: '1',
      isCorrect: true,
      date: DateTime.now().subtract(Duration(days: 6)),
      score: 65,
    ),
    ProblemResult(
      problemId: '2',
      isCorrect: true,
      date: DateTime.now().subtract(Duration(days: 5)),
      score: 72,
    ),
    ProblemResult(
      problemId: '3',
      isCorrect: false,
      date: DateTime.now().subtract(Duration(days: 4)),
      score: 68,
    ),
    ProblemResult(
      problemId: '4',
      isCorrect: true,
      date: DateTime.now().subtract(Duration(days: 3)),
      score: 75,
    ),
    ProblemResult(
      problemId: '5',
      isCorrect: true,
      date: DateTime.now().subtract(Duration(days: 2)),
      score: 80,
    ),
    ProblemResult(
      problemId: '6',
      isCorrect: true,
      date: DateTime.now().subtract(Duration(days: 1)),
      score: 82,
    ),
    ProblemResult(
      problemId: '7',
      isCorrect: true,
      date: DateTime.now(),
      score: 85,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // パーソナライズされたテストがある場合はそれを使用
    if (widget.personalizedTest != null &&
        widget.personalizedTest!['dailyProblems'] != null) {
      final dailyProblems = widget.personalizedTest!['dailyProblems'] as List;

      // 問題の種類ごとに1つを選択
      final selectedProblems = <Problem>[];

      // 通常問題を1つ選択
      final normalProblems =
          dailyProblems.where((problem) => problem['type'] == '通常問題').toList();
      if (normalProblems.isNotEmpty) {
        final selectedNormalProblem = normalProblems[0];
        selectedProblems.add(Problem(
          id: selectedNormalProblem['id'] ?? '',
          title: selectedNormalProblem['question'] ?? '',
          description: selectedNormalProblem['type'] ?? '',
          category: _mapStringToProblemCategory(
              selectedNormalProblem['category'] ?? ''),
          difficulty: 2, // デフォルトの難易度
        ));
      }

      // 音声問題を1つ選択
      final voiceProblems =
          dailyProblems.where((problem) => problem['type'] == '音声問題').toList();
      if (voiceProblems.isNotEmpty) {
        final selectedVoiceProblem = voiceProblems[0];
        selectedProblems.add(Problem(
          id: selectedVoiceProblem['id'] ?? '',
          title: selectedVoiceProblem['question'] ?? '',
          description: selectedVoiceProblem['type'] ?? '',
          category: _mapStringToProblemCategory(
              selectedVoiceProblem['category'] ?? ''),
          difficulty: 2, // デフォルトの難易度
        ));
      }

      // 画像問題を固定で追加
      selectedProblems.add(Problem(
        id: 'image_problem_1',
        title: '画像の中の特定のオブジェクトを見つけてください',
        description: '画像問題',
        category: ProblemCategory.memory,
        difficulty: 2,
      ));

      _dailyProblems = Future.value(selectedProblems);
    } else {
      // デフォルトのモックテスト
      _dailyProblems = Future.value([
        Problem(
          id: '1',
          title: '1週間前の出来事を思い出せますか？',
          description: '通常問題',
          category: ProblemCategory.memory,
          difficulty: 2,
        ),
        Problem(
          id: '2',
          title: '音声を聞いて、正しい答えを選んでください。',
          description: '音声問題',
          category: ProblemCategory.language,
          difficulty: 2,
        ),
        Problem(
          id: 'image_problem_1',
          title: '画像の中の特定のオブジェクトを見つけてください',
          description: '画像問題',
          category: ProblemCategory.memory,
          difficulty: 2,
        )
      ]);
    }

    // モックデータを使用
    _problemResultTrends = Future.value(_mockProblemResultTrends);
  }

  // カテゴリ文字列をenumに変換するヘルパーメソッド
  ProblemCategory _mapStringToProblemCategory(String category) {
    switch (category) {
      case '記憶力':
        return ProblemCategory.memory;
      case '言語能力':
        return ProblemCategory.language;
      case '注意力':
        return ProblemCategory.recall;
      case '計算能力':
        return ProblemCategory.calculation;
      case '見当識':
        return ProblemCategory.orientation;
      default:
        return ProblemCategory.memory; // デフォルト
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('認知トレーニング',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodaysScoreSection(context),
                const SizedBox(height: 16),
                _buildPerformanceChartSection(context),
                const SizedBox(height: 16),
                _buildCategoryPerformanceSection(context),
                const SizedBox(height: 16),
                _buildProblemListSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysScoreSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の成績',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_mockTodaysScore点',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber.shade200,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _mockEncouragementMessage,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChartSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '点数の推移',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: FutureBuilder<List<ProblemResult>>(
              future: _problemResultTrends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('エラーが発生しました'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('データがありません'));
                }

                return SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    dateFormat: DateFormat('M/d'),
                  ),
                  primaryYAxis: NumericAxis(
                    labelFormat: '{value}点',
                    minimum: 0,
                    maximum: 100,
                  ),
                  series: <LineSeries<ProblemResult, DateTime>>[
                    LineSeries<ProblemResult, DateTime>(
                      dataSource: snapshot.data!,
                      xValueMapper: (ProblemResult result, _) => result.date,
                      yValueMapper: (ProblemResult result, _) => result.score,
                      name: '点数',
                      color: Colors.blue,
                      width: 4,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        color: Colors.blue,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    ),
                  ],
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(
                      format: 'point.x : point.y点',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformanceSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'カテゴリ別パフォーマンス',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Column(
            children: _mockCategoryPerformance.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _getCategoryName(entry.key),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPerformanceColor(entry.value),
                          ),
                          minHeight: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${(entry.value * 100).toStringAsFixed(0)}点',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(entry.value),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemListSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の問題',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Problem>>(
            future: _dailyProblems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('エラーが発生しました'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('データがありません'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final problem = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getDifficultyColor(problem.difficulty)
                                .withOpacity(0.1),
                            _getDifficultyColor(problem.difficulty)
                                .withOpacity(0.3),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getDifficultyColor(problem.difficulty),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(problem.difficulty),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(problem.category),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          problem.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          problem.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(problem.difficulty)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getDifficultyText(problem.difficulty),
                            style: TextStyle(
                              color: _getDifficultyColor(problem.difficulty),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => _startProblem(problem),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _startProblem(Problem problem) {
    // カテゴリに応じて適切な画面に遷移
    switch (problem.category) {
      case ProblemCategory.language:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LanguageProblemScreen(problem: problem),
          ),
        );
        break;
      case ProblemCategory.memory:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageRecognitionProblemScreen(problem: problem),
          ),
        );
        break;
      default:
        // 他のカテゴリの問題は既存の問題解決画面に遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProblemSolveScreen(problem: problem),
          ),
        );
    }
  }

  String _getCategoryName(ProblemCategory category) {
    switch (category) {
      case ProblemCategory.memory:
        return '記憶力';
      case ProblemCategory.recall:
        return '想起力';
      case ProblemCategory.calculation:
        return '計算能力';
      case ProblemCategory.language:
        return '言語能力';
      case ProblemCategory.orientation:
        return '見当識';
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '簡単';
      case 2:
        return '普通';
      case 3:
        return '難しい';
      default:
        return '不明';
    }
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 0.8) return Colors.green;
    if (performance >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ProblemCategory category) {
    switch (category) {
      case ProblemCategory.memory:
        return Icons.memory;
      case ProblemCategory.recall:
        return Icons.replay;
      case ProblemCategory.calculation:
        return Icons.calculate;
      case ProblemCategory.language:
        return Icons.language;
      case ProblemCategory.orientation:
        return Icons.navigation;
    }
  }
}

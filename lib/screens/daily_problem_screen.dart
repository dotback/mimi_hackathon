import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../data/models/problem_result.dart';
import '../data/models/problem.dart';
import '../logic/services/problem_service.dart';

class DailyProblemScreen extends StatefulWidget {
  const DailyProblemScreen({super.key});

  @override
  State<DailyProblemScreen> createState() => _DailyProblemScreenState();
}

class _DailyProblemScreenState extends State<DailyProblemScreen> {
  final ProblemService _problemService = ProblemService();
  late Future<List<Problem>> _dailyProblems;
  late Future<Map<ProblemCategory, double>> _categoryPerformance;
  late Future<List<ProblemResult>> _problemResultTrends;

  // モックデータ (DB連携が実装されたら置き換える)
  final int _mockTodaysScore = 75;
  final String _mockEncouragementMessage = '素晴らしい！その調子です！';

  @override
  void initState() {
    super.initState();
    _dailyProblems = _problemService.generateDailyProblems();
    _categoryPerformance = _problemService.getCategoryPerformance();
    _problemResultTrends = _problemService.getProblemResultTrends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日の問題'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaysScoreSection(context),
              _buildPerformanceChartSection(context),
              _buildCategoryPerformanceSection(context),
              _buildProblemListSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // 今日の点数セクション
  Widget _buildTodaysScoreSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日の点数',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_mockTodaysScore点',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(_mockTodaysScore),
                ),
              ),
              const Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _mockEncouragementMessage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  // パフォーマンスチャートセクション
  Widget _buildPerformanceChartSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'これまでの点数',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
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
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                  ],
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(
                      format: 'point.x : point.y',
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

  // カテゴリ別パフォーマンスセクション
  Widget _buildCategoryPerformanceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'カテゴリ別パフォーマンス',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FutureBuilder<Map<ProblemCategory, double>>(
            future: _categoryPerformance,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('エラーが発生しました'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('データがありません'));
              }

              return Column(
                children: snapshot.data!.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getCategoryName(entry.key)),
                            Text(
                              '${(entry.value * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: _getPerformanceColor(entry.value),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 今日の問題リストセクション
  Widget _buildProblemListSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

              return Column(
                children: snapshot.data!
                    .map(
                      (problem) => Card(
                        child: ListTile(
                          title: Text(problem.title),
                          subtitle: Text(problem.description),
                          trailing:
                              Text(_getDifficultyText(problem.difficulty)),
                          onTap: () => _startProblem(problem),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _startProblem(Problem problem) {
    // TODO: 各問題の詳細画面に遷移
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${problem.title}を開始します')),
    );
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

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

class ProblemResult {
  final String problemId;
  final bool isCorrect;
  final DateTime? date;
  final int score;
  final int timeTaken;

  ProblemResult({
    required this.problemId,
    required this.isCorrect,
    this.date,
    this.score = 0,
    this.timeTaken = 0,
  });

  factory ProblemResult.fromJson(Map<String, dynamic> json) {
    return ProblemResult(
      problemId: json['problemId'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      score: json['score'] ?? 0,
      timeTaken: json['timeTaken'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemId': problemId,
      'isCorrect': isCorrect,
      'date': date?.toIso8601String(),
      'score': score,
      'timeTaken': timeTaken,
    };
  }

  // daily_problem_screenで使用される可能性のあるメソッド
  ProblemResult copyWith({
    String? problemId,
    bool? isCorrect,
    DateTime? date,
    int? score,
    int? timeTaken,
  }) {
    return ProblemResult(
      problemId: problemId ?? this.problemId,
      isCorrect: isCorrect ?? this.isCorrect,
      date: date ?? this.date,
      score: score ?? this.score,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }
}

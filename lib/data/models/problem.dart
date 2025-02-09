enum ProblemCategory { memory, recall, calculation, language, orientation }

class Problem {
  final String id;
  final String title;
  final String description;
  final ProblemCategory category;
  final int difficulty;
  final dynamic correctAnswer;
  final String? question;
  final List<String>? answers;
  final String? imagePath;
  final DateTime createdAt;
  final String? type;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.difficulty = 1,
    this.correctAnswer,
    this.question,
    this.answers,
    this.imagePath,
    this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: ProblemCategory.values.firstWhere(
        (e) =>
            e.toString() == 'ProblemCategory.${json['category'] ?? 'memory'}',
      ),
      difficulty: json['difficulty'] ?? 1,
      correctAnswer: json['correctAnswer'],
      question: json['question'],
      answers:
          json['answers'] != null ? List<String>.from(json['answers']) : null,
      imagePath: json['imagePath'],
      type: json['type'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'difficulty': difficulty,
      'correctAnswer': correctAnswer,
      'question': question,
      'answers': answers,
      'imagePath': imagePath,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

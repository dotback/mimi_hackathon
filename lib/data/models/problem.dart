class Problem {
  final String id;
  final String question;
  final List<String> answers;
  final String difficulty;
  final String category;
  final String? imagePath;

  Problem({
    required this.id,
    required this.question,
    required this.answers,
    required this.difficulty,
    required this.category,
    this.imagePath,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      difficulty: json['difficulty'] ?? 'medium',
      category: json['category'] ?? 'general',
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'difficulty': difficulty,
      'category': category,
      'imagePath': imagePath,
    };
  }
} 
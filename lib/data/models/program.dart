class HealthProgram {
  final String id;
  final String name;
  final String description;
  final List<String> exercises;
  final int durationInDays;

  HealthProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.durationInDays,
  });

  // JSONからHealthProgramオブジェクトを作成するコンストラクタ
  factory HealthProgram.fromJson(Map<String, dynamic> json) {
    return HealthProgram(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      exercises: List<String>.from(json['exercises'] ?? []),
      durationInDays: json['durationInDays'] ?? 0,
    );
  }

  // HealthProgramオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises,
      'durationInDays': durationInDays,
    };
  }
} 
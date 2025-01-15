class User {
  final String name;
  final String gender;
  final int age;
  final DateTime birthday;
  final String exerciseHabit;
  final double sleepHours;
  final String email;
  final int? cognitiveFunctionScore;
  final String? cognitiveFunctionComment;

  User({
    required this.name,
    required this.gender,
    required this.age,
    required this.birthday,
    required this.exerciseHabit,
    required this.sleepHours,
    required this.email,
    this.cognitiveFunctionScore,
    this.cognitiveFunctionComment,
  });

  // JSONからUserオブジェクトを作成するコンストラクタ
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      birthday: DateTime.parse(json['birthday']),
      exerciseHabit: json['exerciseHabit'],
      sleepHours: (json['sleepHours'] ?? 0.0).toDouble(),
      email: json['email'] ?? 'guest@example.com',
      cognitiveFunctionScore: json['cognitiveFunctionScore'],
      cognitiveFunctionComment: json['cognitiveFunctionComment'],
    );
  }

  // UserオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'birthday': birthday.toIso8601String(),
      'exerciseHabit': exerciseHabit,
      'sleepHours': sleepHours,
      'email': email,
      'cognitiveFunctionScore': cognitiveFunctionScore,
      'cognitiveFunctionComment': cognitiveFunctionComment,
    };
  }

  // 追加のヘルパーメソッド
  User copyWith({
    String? name,
    String? gender,
    int? age,
    DateTime? birthday,
    String? exerciseHabit,
    double? sleepHours,
    String? email,
    int? cognitiveFunctionScore,
    String? cognitiveFunctionComment,
  }) {
    return User(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      birthday: birthday ?? this.birthday,
      exerciseHabit: exerciseHabit ?? this.exerciseHabit,
      sleepHours: sleepHours ?? this.sleepHours,
      email: email ?? this.email,
      cognitiveFunctionScore: cognitiveFunctionScore ?? this.cognitiveFunctionScore,
      cognitiveFunctionComment: cognitiveFunctionComment ?? this.cognitiveFunctionComment,
    );
  }
} 
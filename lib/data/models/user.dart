class User {
  final String username;
  final String gender;
  final int age;
  final String? birthDate;
  final String exerciseHabit;
  final double sleepHours;
  final String email;
  final int? cognitiveFunctionScore;
  final String? cognitiveFunctionComment;

  User({
    required this.username,
    required this.gender,
    required this.age,
    this.birthDate,
    required this.exerciseHabit,
    required this.sleepHours,
    required this.email,
    this.cognitiveFunctionScore,
    this.cognitiveFunctionComment,
  });

  static User createDefaultUser() {
    return User(
      username: 'ゲストユーザー',
      gender: '未設定',
      age: 30,
      birthDate: null, // Changed to null
      exerciseHabit: '週3回',
      sleepHours: 7.0,
      email: 'guest@example.com',
    );
  }

  // JSONからUserオブジェクトを作成するコンストラクタ
  factory User.fromJson(Map<String, dynamic> json) {
    final double sleepHours = double.parse(json['sleepHours']);
    return User(
      username: json['username'],
      gender: json['gender'],
      age: json['age'],
      birthDate: json['birthDate'], // No need to parse
      exerciseHabit: json['exerciseHabit'],
      sleepHours: sleepHours,
      email: json['email'] ?? 'guest@example.com',
      cognitiveFunctionScore: json['cognitiveFunctionScore'],
      cognitiveFunctionComment: json['cognitiveFunctionComment'],
    );
  }

  // UserオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gender': gender,
      'age': age,
      'birthDate': birthDate, // No need to convert
      'exerciseHabit': exerciseHabit,
      'sleepHours': sleepHours,
      'email': email,
      'cognitiveFunctionScore': cognitiveFunctionScore,
      'cognitiveFunctionComment': cognitiveFunctionComment,
    };
  }

  // 追加のヘルパーメソッド
  User copyWith({
    String? username,
    String? gender,
    int? age,
    String? birthDate,
    String? exerciseHabit,
    double? sleepHours,
    String? email,
    int? cognitiveFunctionScore,
    String? cognitiveFunctionComment,
  }) {
    return User(
      username: username ?? this.username,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      exerciseHabit: exerciseHabit ?? this.exerciseHabit,
      sleepHours: sleepHours ?? this.sleepHours,
      email: email ?? this.email,
      cognitiveFunctionScore:
          cognitiveFunctionScore ?? this.cognitiveFunctionScore,
      cognitiveFunctionComment:
          cognitiveFunctionComment ?? this.cognitiveFunctionComment,
    );
  }
}

class UpdateUser {
  final String? username;
  final String? gender;
  final int? age;
  final String? birthDate;
  final String? exerciseHabit;
  final double? sleepHours;
  final String? email;

  UpdateUser(
      {this.username,
      this.gender,
      this.age,
      this.birthDate,
      this.exerciseHabit,
      this.sleepHours,
      this.email});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gender': gender,
      'age': age,
      'birthDate': birthDate,
      'exerciseHabit': exerciseHabit,
      'sleepHours': sleepHours,
      'email': email,
    };
  }
}

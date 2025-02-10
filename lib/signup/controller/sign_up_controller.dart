import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:mimi/data/models/user.dart';
import 'package:mimi/logic/services/api_service.dart';
import '../../models/file_model.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';

class SignUpController extends GetxController {
  String? _userType;
  String? _email;
  String? _password;
  String? _mobileNumber;
  String? _name;
  String? _collegeName;
  String? _admissionYear;
  String? _passOutYear;
  FileModel? _imageFile;
  FileModel? _resumeFile;
  String? _username;
  String? _gender;
  String? _birthDate;
  int? _age;
  String? _exerciseHabit;
  double? _sleepHours;

  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  String? get userType => _userType;
  String? get email => _email;
  String? get password => _password;
  String? get mobileNumber => _mobileNumber;
  String? get name => _name;
  String? get collegeName => _collegeName;
  String? get admissionYear => _admissionYear;
  String? get passOutYear => _passOutYear;
  FileModel? get imageFile => _imageFile;
  FileModel? get resumeFile => _resumeFile;
  String? get username => _username;
  String? get gender => _gender;
  String? get birthDate => _birthDate;
  int? get age => _age;
  String? get exerciseHabit => _exerciseHabit;
  double? get sleepHours => _sleepHours;

  void setUserType(String value) {
    _userType = value;
    update();
  }

  void setEmail(String value) {
    _email = value;
    update();
  }

  void setPassword(String value) {
    _password = value;
    update();
  }

  void setMobileNumber(String value) {
    _mobileNumber = value;
    update();
  }

  void setName(String value) {
    _name = value;
    update();
  }

  void setSleepHours(double value) {
    _sleepHours = value;
    update();
  }

  void setCollegeName(String value) {
    _collegeName = value;
    update();
  }

  void setAdmissionYear(String value) {
    _admissionYear = value;
    update();
  }

  void setPassOutYear(String value) {
    _passOutYear = value;
    update();
  }

  void setImageFile(FileModel value) {
    _imageFile = value;
    update();
  }

  void setResumeFile(FileModel value) {
    _resumeFile = value;
    update();
  }

  void setAdditionalUserInfo({
    required String username,
    required String gender,
    required String birthDate,
    required int age,
    required String exerciseHabit,
  }) {
    _username = username;
    _gender = gender;
    _birthDate = birthDate;
    _age = age;
    _exerciseHabit = exerciseHabit;
    update();
  }

  Future<bool> registerUser(String email, String password, User user) async {
    try {
      await _authService.signUp(email, password);
      await _apiService.createUser(user);
      return true;
    } catch (e) {
      print('ユーザー登録エラー: $e');
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      // メールアドレスとパスワードのバリデーション
      if (email.isEmpty || password.isEmpty) {
        print('エラー: メールアドレスまたはパスワードが空です');
        return false;
      }

      // デバッグログ
      print('ログイン試行: $email');
      print('パスワード長: ${password.length}');

      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // ログイン成功時の詳細ログ
      print('ログイン成功: ${userCredential.user?.uid}');
      print('ユーザーメール: ${userCredential.user?.email}');

      return userCredential.user != null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // 詳細なエラーログ
      print('FirebaseAuthエラー: ${e.code}');
      print('エラーメッセージ: ${e.message}');

      // エラーコードに基づいたより詳細なエラーハンドリング
      switch (e.code) {
        case 'user-not-found':
          print('ユーザーが見つかりません');
          break;
        case 'wrong-password':
          print('パスワードが間違っています');
          break;
        case 'invalid-email':
          print('メールアドレスの形式が無効です');
          break;
        default:
          print('その他の認証エラー');
      }

      return false;
    } catch (e) {
      // 予期せぬエラーのログ
      print('予期せぬエラー: $e');
      return false;
    }
  }

  Future<void> postSignUpDetails() async {
    // TODO: implement post sign up details
    print("User Type: $_userType");
    print("Email: $_email");
    print("Password: $_password");
    print("Mobile Number: $_mobileNumber");
    print("Name: $_name");
    print("College Name: $_collegeName");
    print("Admission Year: $_admissionYear");
    print("Passout Year: $_passOutYear");
    print("Image File: $_imageFile");
    print("Resume File: $_resumeFile");
  }

  SignUpController();

  void signUp() {
    if (kDebugMode) {
      print('サインアップ処理');
    }
  }
}

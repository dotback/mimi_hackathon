import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
  String? _birthdate;
  int? _age;
  String? _exerciseHabit;
  String? _sleepHabit;

  final AuthService _authService = Get.put(AuthService());

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
  String? get birthdate => _birthdate;
  int? get age => _age;
  String? get exerciseHabit => _exerciseHabit;
  String? get sleepHabit => _sleepHabit;

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
    required String birthdate,
    required int age,
    required String exerciseHabit,
    required String sleepHabit,
  }) {
    _username = username;
    _gender = gender;
    _birthdate = birthdate;
    _age = age;
    _exerciseHabit = exerciseHabit;
    _sleepHabit = sleepHabit;
    update();
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      User? user = await _authService.signUp(email, password);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      // メールアドレスとパスワードのバリデーション
      if (email.isEmpty || password.isEmpty) {
        return false;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      // エラーコードに基づいたより詳細なエラーハンドリング
      switch (e.code) {
        case 'user-not-found':
          break;
        case 'wrong-password':
          break;
        case 'invalid-email':
          break;
        default:
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> postSignUpDetails() async {
    // TODO: implement post sign up details
  }

  SignUpController();

  void signUp() {
    if (kDebugMode) {}
  }
}

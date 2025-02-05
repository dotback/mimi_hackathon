import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:email_validator/email_validator.dart';

// ignore: unused_import
import '../../components/my_button.dart';
import '../../signup/controller/flow_controller.dart';
import '../controller/sign_up_controller.dart';
import '../../components/my_textfield.dart';

import '../../login/login_screen.dart';

class SignUpOne extends StatefulWidget {
  final bool isNarrow;
  const SignUpOne({Key? key, this.isNarrow = false}) : super(key: key);

  @override
  State<SignUpOne> createState() => _SignUpOneState();
}

class _SignUpOneState extends State<SignUpOne> {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final nameController = TextEditingController().obs;

  // コントローラーをGetXから取得
  late SignUpController signUpController;
  late FlowController flowController;

  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    // コントローラーを取得、存在しない場合は作成
    signUpController = Get.find<SignUpController>();
    flowController = Get.find<FlowController>();
  }

  @override
  Widget build(BuildContext context) {
    // 画面のサイズを取得
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isNarrow = screenWidth < 600;

    // レスポンシブなフォントサイズ
    final titleFontSize = isNarrow ? 30.0 : 40.0;
    final labelFontSize = isNarrow ? 14.0 : 16.0;
    final buttonFontSize = isNarrow ? 14.0 : 16.0;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.4, // 画面の40%の高さ
            maxHeight: screenHeight * 0.6, // 最大高さを60%に制限
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.offAll(() => const LoginScreen());
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "新規登録",
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: HexColor("#4f4f4f"),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Input
                      Text(
                        "メールアドレス",
                        style: GoogleFonts.poppins(
                          fontSize: labelFontSize,
                          color: HexColor("#8d8d8d"),
                        ),
                      ),
                      MyTextField(
                        controller: emailController.value,
                        hintText: "メールアドレスを入力",
                        obscureText: false,
                        prefixIcon: const Icon(Icons.mail_outline),
                        onChanged: (String value) {
                          validateEmail(value);
                          signUpController.setEmail(value);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 5),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      // Password Input
                      Text(
                        "パスワード",
                        style: GoogleFonts.poppins(
                          fontSize: labelFontSize,
                          color: HexColor("#8d8d8d"),
                        ),
                      ),
                      MyTextField(
                        controller: passwordController.value,
                        hintText: "パスワードを入力",
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        onChanged: (String value) {
                          signUpController.setPassword(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: MyButton(
                          buttonText: '次へ',
                          onPressed: () async {
                            if (signUpController.email != null &&
                                signUpController.password != null) {
                              // 常に遷移を許可
                              bool isRegistered = true;

                              debugPrint("ユーザー登録結果: $isRegistered");
                              if (isRegistered) {
                                Get.snackbar("成功", "ユーザー登録完了");
                                debugPrint("フロー2に遷移します");
                                flowController.setFlow(2);
                              } else {
                                Get.snackbar(
                                  "エラー",
                                  "ユーザー登録に失敗しました",
                                  backgroundColor: Colors.red.withOpacity(0.7),
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              Get.snackbar(
                                "エラー",
                                "メールアドレスとパスワードを入力してください",
                                backgroundColor: Colors.red.withOpacity(0.7),
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ),
                      // Login Navigation
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "アカウントをお持ちですか？",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: HexColor("#8d8d8d"),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                "ログイン",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: HexColor("#44564a"),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Invalid Email Address";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }
}

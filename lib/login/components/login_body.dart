import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../signup/sign_up_screen.dart';

class LoginBodyScreen extends StatefulWidget {
  const LoginBodyScreen({super.key});

  @override
  State<LoginBodyScreen> createState() => _LoginBodyScreenState();
}

class _LoginBodyScreenState extends State<LoginBodyScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.message ?? "ログインに失敗しました");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  String _errorMessage = "";

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "メールアドレスを入力してください";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "メールアドレスが正しくありません";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isNarrow = screenWidth < 600;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 背景画像
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/R6A_0329.jpg',
                    fit: BoxFit.cover,
                    height: screenHeight * 0.3, // 画面の30%
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.3,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor("#ffffff").withOpacity(0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 20 : 50,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ログイン",
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: HexColor("#4f4f4f"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "メールアドレス",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: HexColor("#8d8d8d"),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MyTextField(
                                  onChanged: (() {
                                    validateEmail(emailController.text);
                                  }),
                                  controller: emailController,
                                  hintText: "メールアドレスを入力してください",
                                  obscureText: false,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "パスワード",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: HexColor("#8d8d8d"),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MyTextField(
                                  controller: passwordController,
                                  hintText: "パスワードを入力してください",
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: MyButton(
                                    onPressed: signUserIn,
                                    buttonText: 'ログイン',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "アカウントをお持ちでない場合",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: HexColor("#8d8d8d"),
                                        ),
                                      ),
                                      TextButton(
                                        child: Text(
                                          "新規登録",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: HexColor("#44564a"),
                                          ),
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const SignUpScreen(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              var begin =
                                                  const Offset(1.0, 0.0);
                                              var end = Offset.zero;
                                              var curve = Curves.easeInOut;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              return SlideTransition(
                                                position:
                                                    animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

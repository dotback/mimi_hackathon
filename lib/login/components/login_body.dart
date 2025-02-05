import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../signup/sign_up_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../signup/controller/sign_up_controller.dart';
import '../../screens/home_screen.dart';

class LoginBodyScreen extends StatefulWidget {
  const LoginBodyScreen({Key? key}) : super(key: key);

  @override
  State<LoginBodyScreen> createState() => _LoginBodyScreenState();
}

class _LoginBodyScreenState extends State<LoginBodyScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignUpController? _signUpController;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    try {
      _signUpController = Get.find<SignUpController>();
    } catch (e) {
      _signUpController = SignUpController();
      Get.put(_signUpController!);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginButtonPressed() async {
    FocusScope.of(context).unfocus();

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        Get.snackbar(
          "エラー",
          "メールアドレスとパスワードを入力してください",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      _isLoading.value = true;

      if (_signUpController == null) {
        throw Exception('SignUpControllerが初期化されていません');
      }

      bool isLoggedIn = await _signUpController!.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      _isLoading.value = false;

      if (isLoggedIn) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          "エラー",
          "ログインに失敗しました。メールアドレスまたはパスワードが正しくありません。",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _isLoading.value = false;

      Get.snackbar(
        "エラー",
        "予期せぬエラーが発生しました: $e",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
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
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  onPressed: () => Get.back(),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "ログイン",
                                  style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor("#4f4f4f"),
                                  ),
                                ),
                              ],
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
                                  controller: _emailController,
                                  hintText: "hello@gmail.com",
                                  obscureText: false,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                  onChanged: (String value) {
                                    _signUpController?.setEmail(value);
                                  },
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
                                  controller: _passwordController,
                                  hintText: "*************",
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  onChanged: (String value) {
                                    _signUpController?.setPassword(value);
                                  },
                                ),
                                const SizedBox(height: 20),
                                Obx(
                                  () => _isLoading.value
                                      ? Center(
                                          child: LoadingAnimationWidget
                                              .staggeredDotsWave(
                                            color: HexColor("#44564a"),
                                            size: 50,
                                          ),
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          child: MyButton(
                                            buttonText: 'ログイン',
                                            onPressed: _loginButtonPressed,
                                          ),
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

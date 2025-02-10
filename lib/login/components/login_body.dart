import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mimi/signup/sign_up_screen.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../signup/controller/sign_up_controller.dart';
import '../../screens/home_screen.dart';
import '../../signup/sign_up_screen.dart';

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
        _signUpController = SignUpController();
        Get.put(_signUpController!);
      }

      bool isLoggedIn = await _signUpController!.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      _isLoading.value = false;

      if (isLoggedIn) {
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAll(() => const HomeScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
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
    } finally {
      _isLoading.value = false;
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
                                ),
                                const SizedBox(height: 20),
                                Obx(() => _isLoading.value
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
                                      )),

                                // 新規登録への動線を追加
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'アカウントをお持ちでない方は',
                                        style: GoogleFonts.poppins(
                                          color: HexColor("#8d8d8d"),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(() => const SignUpScreen());
                                        },
                                        child: Text(
                                          '新規登録',
                                          style: GoogleFonts.poppins(
                                            color: HexColor("#44564a"),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
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

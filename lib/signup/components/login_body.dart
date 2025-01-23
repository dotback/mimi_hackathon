import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../controller/sign_up_controller.dart';
import '../../screens/home_screen.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final SignUpController signUpController = Get.find<SignUpController>();

  // ローディング状態を管理する変数を追加
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    // コントローラーの初期化を確認
    print('LoginBody initState: コントローラーを初期化');
    print('SignUpController email: ${signUpController.email}');
    print('SignUpController password: ${signUpController.password}');
  }

  void _debugPrintControllerValues() {
    if (kDebugMode) {
      print('デバッグ: メールコントローラー - ${emailController.value.text}');
      print('デバッグ: パスワードコントローラー - ${passwordController.value.text}');
      print('デバッグ: SignUpController email - ${signUpController.email}');
      print('デバッグ: SignUpController password - ${signUpController.password}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: 適切な画面に戻る処理を実装
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Input
                  Text(
                    "メールアドレス",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  MyTextField(
                    controller: emailController.value,
                    hintText: "hello@gmail.com",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.mail_outline),
                    onChanged: () {
                      // デバッグログを追加
                      print('メールアドレス変更: ${emailController.value.text}');
                      signUpController.setEmail(emailController.value.text);
                    },
                  ),
                  // Password Input
                  Text(
                    "パスワード",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  MyTextField(
                    controller: passwordController.value,
                    hintText: "*************",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    onChanged: () {
                      // デバッグログを追加
                      print('パスワード変更: ${passwordController.value.text}');
                      signUpController
                          .setPassword(passwordController.value.text);
                    },
                  ),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => _isLoading.value
                          ? Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: HexColor("#44564a"),
                                size: 50,
                              ),
                            )
                          : MyButton(
                              buttonText: 'ログイン',
                              onPressed: () {
                                // デバッグ用のブレークポイント設定可能な関数
                                _loginButtonPressed();
                              },
                            ),
                    ),
                  ),
                  // Sign Up Navigation
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "アカウントをお持ちでないですか？",
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
                          onPressed: () {
                            // TODO: 新規登録画面に遷移
                            Get.to(() => const Scaffold());
                          },
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
    );
  }

  Future<void> _loginButtonPressed() async {
    try {
      // デバッグ情報を出力
      _debugPrintControllerValues();

      // 入力バリデーション
      if (emailController.value.text.isEmpty ||
          passwordController.value.text.isEmpty) {
        print('バリデーションエラー: メールアドレスまたはパスワードが空です');
        Get.snackbar(
          "エラー",
          "メールアドレスとパスワードを入力してください",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // ローディング状態を開始
      _isLoading.value = true;

      // ログイン処理
      print('ログイン処理を開始');
      bool isLoggedIn = await signUpController.loginUser(
        emailController.value.text.trim(),
        passwordController.value.text.trim(),
      );

      // ローディング状態を終了
      _isLoading.value = false;

      print('ログイン結果: $isLoggedIn');

      if (isLoggedIn) {
        // ホーム画面に遷移
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
      // ローディング状態を終了
      _isLoading.value = false;

      print('ログイン中に例外が発生: $e');

      Get.snackbar(
        "エラー",
        "予期せぬエラーが発生しました: $e",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../components/my_button.dart';
import '../../signup/controller/flow_controller.dart';
import '../controller/sign_up_controller.dart';
import '../../components/my_textfield.dart';

class SignUpThree extends StatefulWidget {
  final bool isNarrow;
  const SignUpThree({Key? key, this.isNarrow = false}) : super(key: key);

  @override
  State<SignUpThree> createState() => _SignUpThreeState();
}

class _SignUpThreeState extends State<SignUpThree> {
  SignUpController signUpController = Get.find<SignUpController>();
  FlowController flowController = Get.find<FlowController>();

  @override
  void initState() {
    super.initState();
  }

  final admissionYearController = TextEditingController().obs;
  final passOutYearController = TextEditingController().obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    flowController.setFlow(2);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 67,
                ),
                Text(
                  "新規登録",
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#4f4f4f"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (signUpController.userType == "Student") ...[
                    Text(
                      "入学年度",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextField(
                      controller: admissionYearController.value,
                      hintText: "入学年を入力",
                      obscureText: false,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      keyboardType: TextInputType.number,
                      onChanged: (String value) {
                        signUpController.setAdmissionYear(value);
                      },
                    ),
                  ] else if (signUpController.userType == "Alumni") ...[
                    Text(
                      "卒業年度",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextField(
                      controller: passOutYearController.value,
                      hintText: "卒業年を入力",
                      obscureText: false,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      keyboardType: TextInputType.number,
                      onChanged: (String value) {
                        signUpController.setPassOutYear(value);
                      },
                    ),
                  ] else
                    ...[],
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "プロフィール画像",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyButton(
                    buttonText: 'プロフィール画像をアップロード',
                    onPressed: () {
                      // 画像アップロード機能を無効化
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('現在、画像アップロード機能は利用できません。')),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  GetBuilder<SignUpController>(builder: (context) {
                    return Text(
                      signUpController.imageFile != null
                          ? signUpController.imageFile!.filename
                          : "ファイルが選択されていません",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: HexColor("#8d8d8d"),
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "履歴書 (オプション)",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyButton(
                    buttonText: '履歴書をアップロード',
                    onPressed: () {
                      // 履歴書アップロード機能を無効化
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('現在、履歴書アップロード機能は利用できません。')),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  GetBuilder<SignUpController>(builder: (context) {
                    return Text(
                      signUpController.resumeFile == null
                          ? "ファイルが選択されていません"
                          : signUpController.resumeFile!.filename,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: HexColor("#8d8d8d"),
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      buttonText: '送信',
                      onPressed: () {
                        signUpController.postSignUpDetails();
                      },
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
}

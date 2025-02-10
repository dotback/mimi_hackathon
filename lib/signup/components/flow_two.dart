import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mimi/constants/profile_selection.dart';
import 'package:mimi/data/models/user.dart';
import '../../components/my_button.dart';
import '../../signup/controller/flow_controller.dart';
import '../../signup/controller/sign_up_controller.dart';
import '../../components/my_textfield.dart';
import '../../screens/home_screen.dart';

class SignUpTwo extends StatefulWidget {
  final bool isNarrow;
  const SignUpTwo({Key? key, this.isNarrow = false}) : super(key: key);

  @override
  State<SignUpTwo> createState() => _SignUpTwoState();
}

class _SignUpTwoState extends State<SignUpTwo> {
  final usernameController = TextEditingController();
  final birthdateController = TextEditingController();
  final ageController = TextEditingController();
  final sleepHoursController = TextEditingController();

  String? selectedGender;
  String? selectedExerciseHabit;
  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;

  final List<String> genderOptions = ['男性', '女性', 'その他'];
  final List<String> exerciseHabitOptions = exerciseHabits;

  SignUpController signUpController = Get.find<SignUpController>();
  FlowController flowController = Get.find<FlowController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザー名
              _buildSectionTitle('ユーザー名'),
              MyTextField(
                controller: usernameController,
                hintText: 'ユーザー名を入力',
                inputFormatters: [],
                onChanged: (String value) {
                  if (value.length >= 4) {
                    signUpController.setName(value);
                  }
                },
                obscureText: false,
              ),

              // 性別
              _buildSectionTitle('性別'),
              _buildDropdown(
                value: selectedGender,
                items: genderOptions,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                hint: '性別を選択',
              ),

              // 生年月日と年齢のプルダウン入力
              _buildSectionTitle('生年月日'),
              Row(
                children: [
                  // 年プルダウン
                  Expanded(
                    child: _buildYearDropdown(),
                  ),
                  const SizedBox(width: 8),
                  // 月プルダウン
                  Expanded(
                    child: _buildMonthDropdown(),
                  ),
                  const SizedBox(width: 8),
                  // 日プルダウン
                  Expanded(
                    child: _buildDayDropdown(),
                  ),
                ],
              ),

              // 運動習慣
              _buildSectionTitle('運動習慣'),
              _buildDropdown(
                value: selectedExerciseHabit,
                items: exerciseHabitOptions,
                onChanged: (value) {
                  setState(() {
                    selectedExerciseHabit = value;
                  });
                },
                hint: '運動習慣を選択',
              ),

              // 睡眠習慣
              _buildSectionTitle('睡眠習慣'),
              MyTextField(
                controller: sleepHoursController,
                hintText: '7.5',
                obscureText: false,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{1,2}(\.|(\.\d))?$')),
                ],
                onChanged: (String value) {
                  signUpController.setSleepHours(double.tryParse(value) ?? 0.0);
                },
              ),
              const SizedBox(height: 20),
              MyButton(
                buttonText: '登録',
                onPressed: () async {
                  // 入力値の検証
                  if (_validateInputs()) {
                    // SignUpControllerに追加情報を設定
                    signUpController.setAdditionalUserInfo(
                      username: usernameController.value.text,
                      gender: selectedGender!,
                      birthDate: birthdateController.value.text,
                      age: int.parse(ageController.value.text),
                      exerciseHabit: selectedExerciseHabit!,
                    );

                    // ユーザー登録を実行
                    bool isRegistered = await signUpController.registerUser(
                      signUpController.email.toString(),
                      signUpController.password.toString(),
                      User(
                        username: signUpController.username.toString(),
                        gender: signUpController.gender.toString(),
                        age: signUpController.age ?? 0,
                        birthDate: signUpController.birthDate,
                        exerciseHabit:
                            signUpController.exerciseHabit.toString(),
                        sleepHours: signUpController.sleepHours ?? 0.0,
                        email: signUpController.email.toString(),
                      ),
                    );

                    if (isRegistered) {
                      // 登録成功時の処理
                      Get.snackbar("成功", "ユーザー登録が完了しました");
                      Get.offAll(() => HomeScreen());
                    } else {
                      Get.snackbar("エラー", "登録に失敗しました");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (usernameController.value.text.isEmpty) {
      Get.snackbar("エラー", "ユーザー名を入力してください");
      return false;
    }
    if (selectedGender == null) {
      Get.snackbar("エラー", "性別を選択してください");
      return false;
    }
    if (birthdateController.value.text.isEmpty) {
      Get.snackbar("エラー", "生年月日を選択してください");
      return false;
    }
    if (selectedExerciseHabit == null) {
      Get.snackbar("エラー", "運動習慣を選択してください");
      return false;
    }
    return true;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: HexColor("#8d8d8d"),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // 年齢計算メソッド
  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(100, (index) => currentYear - index - 10);

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '年',
        border: OutlineInputBorder(),
      ),
      value: selectedYear,
      hint: Text('年'),
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (selectedYear) {
        setState(() {
          this.selectedYear = selectedYear;
          _updateBirthdateController();
          // 年齢自動計算
          ageController.text = (DateTime.now().year - selectedYear!).toString();
        });
      },
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '月',
        border: OutlineInputBorder(),
      ),
      value: selectedMonth,
      hint: Text('月'),
      items: List.generate(12, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1}月'),
        );
      }),
      onChanged: (selectedMonth) {
        setState(() {
          this.selectedMonth = selectedMonth;
          _updateBirthdateController();
        });
      },
    );
  }

  Widget _buildDayDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '日',
        border: OutlineInputBorder(),
      ),
      value: selectedDay,
      hint: Text('日'),
      items: List.generate(31, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1}日'),
        );
      }),
      onChanged: (selectedDay) {
        setState(() {
          this.selectedDay = selectedDay;
          _updateBirthdateController();
        });
      },
    );
  }

  void _updateBirthdateController() {
    if (selectedYear != null && selectedMonth != null && selectedDay != null) {
      birthdateController.text =
          '$selectedYear-${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}';
    }
  }
}

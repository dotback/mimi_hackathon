import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import '../controller/flow_controller.dart';

import 'flow_one.dart';
import 'flow_three.dart';
import 'flow_two.dart';

class SignUpBodyScreen extends StatelessWidget {
  const SignUpBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // コントローラーを確実に初期化
    final FlowController flowController = Get.put(FlowController());

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isNarrow = screenWidth < 600;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
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
                        top: screenHeight * 0.3, // 画像の下に配置
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor("#ffffff"),
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
                          child: GetBuilder<FlowController>(
                            init: flowController,
                            builder: (controller) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildSignUpFlow(
                                  controller.currentFlow,
                                  isNarrow,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpFlow(int currentFlow, bool isNarrow) {
    switch (currentFlow) {
      case 1:
        return SignUpOne(
          key: const ValueKey(1),
          isNarrow: isNarrow,
        );
      case 2:
        return SignUpTwo(
          key: const ValueKey(2),
          isNarrow: isNarrow,
        );
      case 3:
        return SignUpThree(
          key: const ValueKey(3),
          isNarrow: isNarrow,
        );
      default:
        return SignUpOne(
          key: const ValueKey(1),
          isNarrow: isNarrow,
        );
    }
  }
}

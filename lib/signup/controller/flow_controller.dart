import 'package:get/get.dart';

class FlowController extends GetxController {
  final _currentFlow = 1.obs;

  int get currentFlow => _currentFlow.value;

  void setFlow(int flow) {
    print('フロー変更: $flow'); // デバッグ用のログ
    _currentFlow.value = flow;
    update(); // GetXのupdate()を呼び出して状態を更新
  }

  @override
  void onInit() {
    super.onInit();
    print('FlowControllerが初期化されました。初期フロー: $currentFlow');
  }
}

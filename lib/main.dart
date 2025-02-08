import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart' show PlatformDispatcher;

import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 詳細なエラーロギングを追加
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Framework Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
    FlutterError.dumpErrorToConsole(details);
  };

  // Firebase初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase初期化成功');
  } catch (e) {
    print('Firebase初期化エラー: $e');
  }

  // 環境変数の読み込
  String geminiApiKey = '';
  String cloudRunApiKey = '';

  try {
    // Cloud Run環境の環境変数を最初に確認
    cloudRunApiKey = const String.fromEnvironment('GEMINI_API_KEY');
  } catch (e) {
    print('Cloud Run環境変数の読み込みエラー: $e');
  }

  if (cloudRunApiKey.isNotEmpty) {
    // Cloud Run環境変数が存在する場合はそれを使用
    geminiApiKey = cloudRunApiKey;
    print('Cloud Run環境: Gemini APIキーが正常に読み込まれました');
  } else {
    // Cloud Run環境変数がない場合は.envから読み込み
    await dotenv.load(fileName: '.env');
    geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    print('ローカル環境: .envからGemini APIキーを読み込みました');
  }

  // APIキーが取得できた場合のみGetXに登録
  if (geminiApiKey.isNotEmpty) {
    Get.put<String>(geminiApiKey, tag: 'geminiApiKey');
    print('APIキーの長さ: ${geminiApiKey.length}');
  } else {
    print('警告: Gemini APIキーが見つかりませんでした');
  }

  // SharedPreferencesを初期化
  try {
    await SharedPreferences.getInstance();
    print('SharedPreferences初期化成功');
  } catch (e) {
    print('SharedPreferences初期化エラー: $e');
  }

  // AuthServiceをGetに登録
  Get.lazyPut(() => AuthService());

  // グローバルエラーハンドリング
  PlatformDispatcher.instance.onError = (error, stack) {
    print('キャッチされていないエラー: $error');
    print('スタックトレース: $stack');
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('MyAppのビルド開始');

    return GetMaterialApp(
      title: 'みんなの認知機能アプリ',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.murechoTextTheme(),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          maintainState: false,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          maintainState: false,
        ),
      ],
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorKey: Get.key,
    );
  }
}

// 他のスクリーンやサービスでAPIキーを取得する例は不要なので削除
// APIキーの使用例は各画面で直接実装する

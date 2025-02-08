import 'package:envied/envied.dart';

part 'env.g.dart'; // ファイルの先頭に！

@Envied(path: '.env') // path の指定は正しいか？
abstract class Env {
  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static final String geminiApiKey = _Env.geminiApiKey; // _Env クラスを参照
}

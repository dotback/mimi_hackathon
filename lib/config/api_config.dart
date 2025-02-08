class ApiConfig {
  // APIサーバーのベースURL
  static const String baseUrl = 'http://127.0.0.1:5001/mimi-dev-c7ee3';

  // エンドポイント
  static const String userProfileEndpoint = '/us-central1/users';

  // 認証トークン（必要に応じて）
  static String? authToken =
      'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImF1dGhfdGltZSI6MTczODU5OTg5MywidXNlcl9pZCI6ImdZc1lpd1BjVm9uQjA0UGF4NEEycDhiUE9ZeDIiLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInRlc3RAZXhhbXBsZS5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9LCJpYXQiOjE3Mzg1OTk4OTMsImV4cCI6MTczODYwMzQ5MywiYXVkIjoibWltaS1kZXYtYzdlZTMiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbWltaS1kZXYtYzdlZTMiLCJzdWIiOiJnWXNZaXdQY1ZvbkIwNFBheDRBMnA4YlBPWXgyIn0.';

  // 環境設定（開発、本番など）
  static const bool isDevelopment = true;
}

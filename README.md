# Mimi - 認知機能トレーニングアプリ

## 環境バージョン

- Flutter Version Management (FVM): 3.2.1
- Flutter: 3.27.1
- Dart: 3.6.0

## ローカルでのセットアップ
自前に下記レポジトリのfirebaseのemulatorを起動しておく  
https://github.com/dotback/mimi_hackathon

```
$ cp .env.sample .env
$ vi .env # gemini api keyを設定
$ flutter pub get
$ flutter run -d chrome
```

## プロジェクト構造

### ディレクトリ構成

```
mimi/
├── android/           # Android固有の設定
├── ios/               # iOS固有の設定
├── linux/             # Linux固有の設定
├── macos/             # macOS固有の設定
├── web/               # Web固有の設定
├── windows/           # Windows固有の設定
├── lib/
│   ├── components/    # 共通コンポーネント
│   ├── config/        # 設定関連
│   ├── controller/    # コントローラー
│   ├── data/          # データレイヤー
│   │   ├── models/    # データモデル定義
│   ├── homepage/      # ホーム画面関連
│   ├── logic/         # ビジネスロジック
│   │   ├── services/  # アプリケーションサービス
│   ├── login/         # ログイン関連
│   ├── models/        # 追加のモデル
│   ├── screens/       # 画面
│   ├── services/      # サービス
│   ├── signup/        # サインアップ関連
│   ├── utils/         # ユーティリティ
│   ├── widgets/       # 共通ウィジェット
│   ├── firebase_options.dart  # Firebase設定
│   └── main.dart      # アプリケーションエントリーポイント
├── test/              # テストコード
├── assets/            # 静的アセット
└── .env               # 環境変数

```

### 主要なディレクトリと特性

- **`lib/`**: アプリケーションのメインソースコードを含む

  - `components/`: 再利用可能な UI コンポーネント
  - `config/`: アプリケーション設定
  - `controller/`: 状態管理とコントロールロジック
  - `data/`: データモデルとリポジトリ
  - `homepage/`: ホーム画面関連のコード
  - `logic/`: ビジネスロジックとサービス
  - `login/`: ログイン関連の機能
  - `models/`: データモデル
  - `screens/`: アプリの各画面
  - `services/`: 外部サービスとの連携
  - `signup/`: サインアップ関連の機能
  - `utils/`: ユーティリティ関数
  - `widgets/`: 共通ウィジェット

- **`android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`**: プラットフォーム固有の設定と実装

- **`test/`**: アプリケーションのテストコード

- **`assets/`**: 画像、フォント、その他の静的リソース

- **`.env`**: 環境変数の設定

## 注意点

- **ローカルストレージのみ**: 現在のバージョンはサーバー接続を完全に無効化
- すべてのデータは端末内の Shared Preferences に保存
- テスト結果は最新の 10 件のみ保持
- バックアップや同期機能は現在利用できません

## 将来の開発予定

- サーバーバックエンドの実装
- クラウド同期機能
- データのエクスポート/インポート
- セキュリティの強化

## 推奨される開発環境

- Flutter: 3.27.1
- Dart: 3.6.0
- FVM: 3.2.1

## ライセンス

[MIT ライセンス](LICENSE)

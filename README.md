# Mimi - 認知機能トレーニングアプリ

## 環境バージョン

- Flutter Version Management (FVM): 3.2.1
- Flutter: 3.27.1
- Dart: 3.6.0

## アプリ概要

Mimi は、ユーザーの認知機能を評価し、改善するためのローカルストレージベースのモバイルアプリケーションです。主な機能は以下の通りです：

- 認知機能テスト
- パーソナライズされた改善提案
- ユーザープロファイル管理
- 進捗トラッキング

## 重要な特徴

- **完全なローカルストレージ**: 現在のバージョンでは、すべてのデータをローカルに保存
- テスト結果は端末内に安全に保存
- 最新の 10 件のテスト履歴を保持
- サーバー接続は無効化されています

## プロジェクト構造

### ディレクトリ構成

```
mimi/
├── android/           # Android固有の設定
├── ios/               # iOS固有の設定
├── lib/
│   ├── data/          # データレイヤー
│   │   ├── models/    # データモデル定義
│   │   └── repositories/ # データアクセスロジック
│   ├── logic/         # ビジネスロジック
│   │   ├── services/  # アプリケーションサービス
│   │   └── cubits/    # 状態管理
│   └── presentation/  # UI関連
│       ├── screens/   # 画面
│       └── widgets/   # 共通ウィジェット
└── test/              # テストコード
```

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

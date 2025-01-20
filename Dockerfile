# Flutterウェブアプリケーション用のDockerfile

# ベースイメージを更新
FROM debian:bullseye-slim AS build

# 必要な依存関係のインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    libgconf-2-4 \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Flutterのインストール（最新の安定版）
RUN git clone https://github.com/flutter/flutter.git /flutter \
    && cd /flutter \
    && git checkout stable

# パスの設定
ENV PATH="/flutter/bin:${PATH}"
ENV FLUTTER_ROOT="/flutter"

# Webサポートの有効化
RUN flutter config --enable-web

# 作業ディレクトリの設定
WORKDIR /app

# プロジェクトファイルのコピー
COPY pubspec.* ./

# 依存関係のダウンロード
RUN flutter pub get

# プロジェクト全体のコピー
COPY . .

# Webアプリのビルド（デバッグ情報を追加）
RUN flutter build web --verbose

# 軽量なウェブサーバーを使用する最終ステージ
FROM nginx:alpine

# ビルドされたウェブアプリをNginxにコピー
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginxのデフォルト設定を上書き
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Cloud Run用のエントリーポイントスクリプトを追加
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# デフォルトポートを8080に変更
EXPOSE 8080

# エントリーポイントスクリプトを実行
ENTRYPOINT ["/entrypoint.sh"] 
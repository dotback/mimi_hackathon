# Flutterウェブアプリケーション用のDockerfile

# Flutterの安定版イメージを使用
FROM debian:bullseye-slim AS build

# 必要な依存関係のインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Flutterのインストール
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz -O flutter.tar.xz \
    && tar xf flutter.tar.xz \
    && rm flutter.tar.xz

# パスの設定
ENV PATH="/flutter/bin:${PATH}"

# 作業ディレクトリの設定
WORKDIR /app

# プロジェクトファイルのコピー
COPY pubspec.* ./
RUN flutter pub get

# プロジェクト全体のコピー
COPY . .

# Webアプリのビルド
RUN flutter build web

# 軽量なウェブサーバーを使用する最終ステージ
FROM nginx:alpine

# ビルドされたウェブアプリをNginxにコピー
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginxのデフォルト設定を上書き（必要に応じて）
COPY nginx.conf /etc/nginx/conf.d/default.conf

# ポート80を公開
EXPOSE 80

# Nginxを起動
CMD ["nginx", "-g", "daemon off;"] 
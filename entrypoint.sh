#!/bin/sh

# デフォルトポートを8080に設定
PORT=${PORT:-8080}

# Nginx設定ファイルのポート変数を置換
sed -i "s/\$PORT/$PORT/g" /etc/nginx/conf.d/default.conf

# Nginxを起動
nginx -g "daemon off;" 
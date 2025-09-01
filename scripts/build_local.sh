#!/bin/bash

# ローカル開発用ビルドスクリプト
# 環境変数からAPIキーを読み込んでビルド

echo "🔧 ローカル開発用ビルドを開始..."

# 環境変数ファイルを読み込み
if [ -f .env.local ]; then
    echo "📁 .env.local ファイルを読み込み中..."
    export $(cat .env.local | xargs)
else
    echo "⚠️  .env.local ファイルが見つかりません"
    echo "📝 プロジェクトルートに .env.local ファイルを作成してください:"
    echo "   GOOGLE_MAPS_API_KEY=your_api_key_here"
    exit 1
fi

# APIキーが設定されているか確認
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "❌ GOOGLE_MAPS_API_KEY が設定されていません"
    exit 1
fi

echo "✅ APIキー確認完了: ${GOOGLE_MAPS_API_KEY:0:10}..."

# Flutter Web ビルド
echo "🚀 Flutter Web ビルド中..."
flutter build web --release --dart-define=DEMO=true

# APIキーを置き換え
echo "🔑 APIキーを置き換え中..."
sed -i "s/PRODUCTION_API_KEY_HERE/$GOOGLE_MAPS_API_KEY/g" build/web/index.html

echo "✅ ローカル開発用ビルド完了！"
echo "🌐 サーバー起動: flutter run -d chrome"

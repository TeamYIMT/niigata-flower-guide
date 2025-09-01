@echo off
REM ローカル開発用ビルドスクリプト (Windows)
REM 環境変数からAPIキーを読み込んでビルド

echo 🔧 ローカル開発用ビルドを開始...

REM 環境変数ファイルを読み込み
if exist .env.local (
    echo 📁 .env.local ファイルを読み込み中...
    for /f "tokens=1,2 delims==" %%a in (.env.local) do set %%a=%%b
) else (
    echo ⚠️  .env.local ファイルが見つかりません
    echo 📝 プロジェクトルートに .env.local ファイルを作成してください:
    echo    GOOGLE_MAPS_API_KEY=your_api_key_here
    pause
    exit /b 1
)

REM APIキーが設定されているか確認
if "%GOOGLE_MAPS_API_KEY%"=="" (
    echo ❌ GOOGLE_MAPS_API_KEY が設定されていません
    pause
    exit /b 1
)

echo ✅ APIキー確認完了: %GOOGLE_MAPS_API_KEY:~0,10%...

REM Flutter Web ビルド
echo 🚀 Flutter Web ビルド中...
flutter build web --release --dart-define=DEMO=true

REM APIキーを置き換え
echo 🔑 APIキーを置き換え中...
powershell -Command "(Get-Content build/web/index.html) -replace 'PRODUCTION_API_KEY_HERE', '%GOOGLE_MAPS_API_KEY%' | Set-Content build/web/index.html"

echo ✅ ローカル開発用ビルド完了！
echo 🌐 サーバー起動: flutter run -d chrome
pause

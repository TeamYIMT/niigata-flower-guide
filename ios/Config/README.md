# iOS Google Maps APIキー設定

## 📱 初回セットアップ手順

### 1. APIキー設定ファイルの作成

```bash
# テンプレートをコピーして設定ファイルを作成
cp ios/Config/Keys.xcconfig.template ios/Config/Keys.xcconfig
```

### 2. APIキーの設定

`ios/Config/Keys.xcconfig` ファイルを開いて、`YOUR_GOOGLE_MAPS_API_KEY_HERE` を実際のAPIキーに置き換えてください。

```xcconfig
// iOS用Google Maps APIキー
GOOGLE_MAPS_API_KEY = あなたのAPIキーをここに入力
```

### 3. Google Cloud Console設定

APIキーは以下の設定が必要です：

- **アプリケーションの制限**: iOSアプリ
- **バンドルID**: `com.example.niigataFlowerGuide`
- **有効なAPI**: 
  - Maps SDK for iOS
  - Maps Static API
  - Geocoding API

### 4. ビルドテスト

```bash
# 設定が正しいかテスト
flutter build ios --no-codesign
```

## ⚠️ 注意事項

- `Keys.xcconfig` ファイルは`.gitignore`に登録されているため、リポジトリにコミットされません
- APIキーは絶対に公開リポジトリにコミットしないでください
- チームメンバーは各自でAPIキーを設定する必要があります

## 🔧 トラブルシューティング

### 地図が表示されない場合

1. APIキーが正しく設定されているか確認
2. Google Cloud Console でAPIが有効化されているか確認
3. バンドルIDが正しく設定されているか確認
4. Xcodeのログでエラーメッセージを確認 

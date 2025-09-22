## Day4 追加: データ拡充 / コスト最適化 / Webプレビュー

- データ拡充: `assets/data/spots.json` と `functions/data/spots.json` を50件に拡充
- コスト最適化:
  - モデル: `gemini-1.5-flash`
  - 前処理で候補を最大12件に圧縮（距離昇順）
  - Directionsは入力変更時のみ実行（現状は直線ポリラインで代替）
- プロンプト強化: 理由に「季節/距離/体験価値」を必ず含める
- Webプレビュー: GitHub Actions（branch: `hackathon-2025`, channelId: `hackathon-2025`）

### 環境変数/Secrets
- ローカル: `GOOGLE_APPLICATION_CREDENTIALS`, `USE_VERTEX=1`, `VERTEX_MODEL=gemini-1.5-flash`, `FUNCTIONS_REGION=asia-northeast1`
- GitHub Secrets: `FIREBASE_TOKEN`, `FIREBASE_PROJECT_ID`（例: `flower-guide-hackathon-2025`）

### デプロイ（Web）
1) リポジトリの `hackathon-2025` ブランチへ push
2) Actions が `flutter build web` → Hosting へ preview deploy（channel: hackathon-2025）

### 検証
- Curl:
  `curl -s -X POST http://127.0.0.1:5001/flower-guide-hackathon-2025/asia-northeast1/plan -H "content-type: application/json" -d "{}"`
- Flutter Web: `flutter run -t lib/hackathon/main_hackathon.dart -d chrome`


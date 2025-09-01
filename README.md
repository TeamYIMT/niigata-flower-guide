# Niigata花図鑑

新潟県の花々をAR技術で楽しめるスマートフォンアプリケーション

🌐 **GitHub Pages で公開中**: [https://teamyimt.github.io/niigata-flower-guide/](https://teamyimt.github.io/niigata-flower-guide/)

## 📱 概要

新潟県の季節ごとの花々を地域別に楽しめるスマホアプリです。AR技術を活用し、実際のスポットを訪れると、カメラ越しにチューリップやアジサイなどの花がデジタルに咲き誇ります。新潟の美しい自然と四季折々の花を臨場感たっぷりに紹介します。

## ✨ 主な機能

- **AR花の開花演出**: GPS連動で特定の場所で花が開花するARビジュアル
- **花の物語システム**: 各花スポットでのAR体験と地域の歴史・文化情報、観光情報を表示
- **マップ連携**: 花スポットの案内と季節ごとの推奨ルート提案
- **SNS共有機能**: ARで撮影した花の写真や動画をワンタップで共有
- **スタンプラリー**: 訪れたスポットごとにデジタル花スタンプを収集

## 🎯 対象ユーザー

- 観光客: 新潟を初めて訪れる旅行者
- 地元の家族: 週末のお出かけで楽しめるコンテンツを求める新潟在住の親子連れ
- 若年層: スマホでのインタラクティブな体験やSNSでシェアできるコンテンツを好む若者世代

## 🛠 技術スタック

- Flutter
- AR技術
- GPS連動
- SNS連携

## 📖 使用方法

1. アプリを起動し、現在地周辺の花スポットを確認
2. スポットに到着したら、ARカメラを起動
3. 花の開花演出を体験し、写真や動画を撮影
4. SNSで共有して、デジタルスタンプを獲得

## 🤝 協力・連携

- 新潟県や各市町村の観光課
- 観光協会
- 教育機関
- 地域住民

## アーキテクチャ

### データ管理戦略

#### 現在の実装（ローカル JSON）
- スポット数: 8件
- データ管理: `lib/data/spots.dart`
- 利点: 完全無料、高速、オフライン対応

#### Firestore移行時の料金試算

スポット数が30件を超えた場合のCloud Firestore移行時の料金試算：

##### 想定利用パターン
- 月間アクティブユーザー: 1,000人
- 1人あたり平均セッション: 5回/月
- 1セッションあたり平均スポット閲覧: 3件
- 1スポットあたり平均スタンプ取得: 0.5件/セッション

##### 読み込み操作
```
月間読み込み = 1,000人 × 5セッション × 3スポット = 15,000 reads/月
```

##### 書き込み操作
```
月間書き込み = 1,000人 × 5セッション × 0.5スタンプ = 2,500 writes/月
```

##### 料金計算（2024年12月時点）
- 読み込み: 15,000 reads × $0.06/100,000 = $0.009/月
- 書き込み: 2,500 writes × $0.18/100,000 = $0.0045/月
- 合計: 約$0.014/月（約2円/月）

##### 無料枠との比較
- 読み込み無料枠: 50,000 reads/月 → 余裕あり
- 書き込み無料枠: 20,000 writes/月 → 余裕あり
- 削除無料枠: 20,000 deletes/月 → 余裕あり

**結論**: 現在の利用想定では、Firestore移行後も無料枠内で運用可能

#### 課金抑制戦略

1. **ページング実装**
   ```dart
   // 一度に取得するスポット数を制限
   Query query = spots.limit(10);
   ```

2. **キャッシュ活用**
   ```dart
   // オフライン持続性を有効化
   FirebaseFirestore.instance.settings = Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
   );
   ```

3. **条件付きクエリ**
   ```dart
   // 位置情報に基づく範囲クエリ
   Query query = spots.where('latitude', isGreaterThan: minLat)
                     .where('latitude', isLessThan: maxLat);
   ```

## 開発環境

- Flutter SDK: 3.8.1+
- Dart: 3.8.1+
- Firebase: 最新版

## セットアップ

1. 依存関係をインストール
```bash
flutter pub get
```

2. Firebase設定
```bash
# Firebase CLIでプロジェクトを設定
firebase login
firebase init
```

3. アプリを起動
```bash
flutter run
```

## 使用技術

- Flutter/Dart
- Firebase Authentication
- Cloud Firestore
- Google Maps API
- Provider (状態管理)
- Geolocator (位置情報)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。


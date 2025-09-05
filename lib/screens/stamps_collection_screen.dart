import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp.dart';
import '../data/spots.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/share_service.dart';

/// スタンプコレクション画面
/// - embedded = true のとき：HomeScreen のタブに埋め込む用（戻る/子ナビを非表示）
/// - embedded = false のとき：単体画面として使う（戻る/子ナビを表示）
class StampCollectionScreen extends StatelessWidget {
  final bool embedded;
  const StampCollectionScreen({Key? key, this.embedded = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        // 背景画像
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/backgroundflower.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // 埋め込み時は戻るボタンを消す（レイアウトは保つ）
                    embedded
                        ? const SizedBox(width: 48)
                        : IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                    const Expanded(
                      child: Text(
                        'スタンプコレクション',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<StampProvider>().refreshStamps(),
                      icon: const Icon(Icons.refresh),
                      tooltip: '再読み込み',
                    ),
                  ],
                ),
              ),

              // スタンプ／バッジ切り替え（今回はスタンプのみ）
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('スタンプ'),
                      selected: true,
                      onSelected: (_) {},
                      selectedColor: Colors.green.shade200,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('バッジ'),
                      selected: false,
                      onSelected: (_) {},
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),

              // スタンプグリッド
              Expanded(
                child: Consumer<StampProvider>(
                  builder: (context, stampProvider, child) {
                    if (stampProvider.isLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('スタンプを読み込み中...'),
                          ],
                        ),
                      );
                    }

                    // デモスポットを除いた実際のスポット一覧
                    final actualSpots = spots.where((s) => !s.isDemo).toList();
                    final stamps = stampProvider.stamps;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        itemCount: actualSpots.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final spot = actualSpots[index];

                          // スタンプ取得済みか
                          Stamp? collectedStamp;
                          try {
                            collectedStamp =
                                stamps.firstWhere((st) => st.spotTitle == spot.title);
                          } catch (_) {
                            collectedStamp = null;
                          }
                          final isCollected = collectedStamp != null;

                          return GestureDetector(
                            onTap: () => isCollected
                                ? _showStampDetail(context, collectedStamp!)
                                : _showUncollectedSpotDetail(context, spot, embedded),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCollected ? Colors.green : Colors.grey,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isCollected
                                    ? Image.asset(
                                        spot.stampImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.green.shade100,
                                          child: Icon(Icons.star,
                                              size: 40, color: Colors.green.shade600),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade100,
                                        child: Image.asset(
                                          'assets/images/question.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.help_outline,
                                            size: 40,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 進捗表示（子ナビは embedded=false のときだけ表示）
              Consumer<StampProvider>(
                builder: (context, stampProvider, child) {
                  final total = spots.where((s) => !s.isDemo).length;
                  final collectedCount = stampProvider.stamps
                      .where((st) => !spots.any((sp) => sp.isDemo && sp.title == st.spotTitle))
                      .length;

                  final progress = total == 0 ? 0.0 : collectedCount / total;

                  final progressSection = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '取得済み: $collectedCount / $total',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.green.shade100,
                          color: Colors.green,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  );

                  if (embedded) {
                    // 親(HomeScreen)がナビを持つので、ここでは進捗だけ表示
                    return progressSection;
                  }

                  // 単体画面として使う場合のみ、子ナビを表示
                  return Column(
                    children: [
                      progressSection,
                      BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        currentIndex: 3,
                        selectedItemColor: Colors.green,
                        unselectedItemColor: Colors.grey,
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
                          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ARカメラ'),
                          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
                          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
                        ],
                        onTap: (index) {
                          switch (index) {
                            case 0:
                              Navigator.pushNamed(context, '/home');
                              break;
                            case 2:
                              Navigator.pushNamed(context, '/unity');
                              break;
                            case 4:
                              // プロフィールに飛ばしたい場合だけ有効に
                              // Navigator.pushNamed(context, '/profile');
                              break;
                            default:
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ホーム画面のタブから移動してください')),
                              );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );

    // 埋め込み時はそのまま返し、単体利用時は Scaffold で包む
    return embedded ? content : Scaffold(body: content);
  }

  void _showStampDetail(BuildContext context, Stamp stamp) {
    final spot = spots.firstWhere(
      (sp) => sp.title == stamp.spotTitle,
      orElse: () => spots.where((sp) => !sp.isDemo).first,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // スタンプ画像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      spot.stampImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.green.shade100,
                        child: Icon(Icons.star, size: 50, color: Colors.green.shade600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // スポット情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (spots.any((sp) => sp.isDemo && sp.title == stamp.spotTitle)) ...[
                      Icon(Icons.science, size: 20, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        stamp.spotTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stamp.spotLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 取得日時
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('取得日時', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${stamp.collectedAt.year}年${stamp.collectedAt.month}月${stamp.collectedAt.day}日 '
                        '${stamp.collectedAt.hour.toString().padLeft(2, '0')}:${stamp.collectedAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 共有ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: const Text('SNSで共有'),
                    onPressed: () async {
                      // スタンプ画像をアセットから読み込み
                      final bytes = await rootBundle.load(spot.stampImage);

                      // キャプション生成
                      final caption = [
                        '【スタンプ取得】${stamp.spotTitle}',
                        '#Niigata花図鑑 #デジタルスタンプ',
                      ].join('\n');

                      await ShareService.shareImageBytes(
                        imageBytes: bytes.buffer.asUint8List(),
                        filename: 'stamp_${DateTime.now().millisecondsSinceEpoch}.png',
                        text: caption,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 閉じるボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('閉じる'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUncollectedSpotDetail(BuildContext context, dynamic spot, bool embedded) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 未取得スタンプ画像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 3),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Image.asset(
                        'assets/images/question.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.help_outline, size: 50, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // スポット情報
                Text(
                  spot.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  spot.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 未取得メッセージ
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.location_on, size: 32, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      const Text('スタンプ未取得',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'このスポットを訪れて\nスタンプを取得しましょう！',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ボタン
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (embedded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('下の「マップ」タブから開いてください')),
                            );
                          } else {
                            // 単体起動時はホームへ戻るなど必要に応じて調整
                            Navigator.pushNamed(context, '/home');
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('マップで確認'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('閉じる'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

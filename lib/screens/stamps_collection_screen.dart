import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp.dart';
import '../data/spots.dart';

/// スタンプコレクション画面のウィジェット
class StampCollectionScreen extends StatelessWidget {
  const StampCollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'スタンプコレクション',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<StampProvider>().refreshStamps();
                        },
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

                      // デモスポットを除いた実際のスポット一覧を取得
                      final actualSpots = spots.where((spot) => !spot.isDemo).toList();
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
                            // このスポットのスタンプが取得済みかチェック
                            Stamp? collectedStamp;
                            try {
                              collectedStamp = stamps.firstWhere(
                                (stamp) => stamp.spotTitle == spot.title,
                              );
                            } catch (e) {
                              collectedStamp = null;
                            }
                            final isCollected = collectedStamp != null;

                            return GestureDetector(
                              onTap: () => isCollected 
                                ? _showStampDetail(context, collectedStamp!)
                                : _showUncollectedSpotDetail(context, spot),
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
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.green.shade100,
                                            child: Icon(
                                              Icons.star,
                                              size: 40,
                                              color: Colors.green.shade600,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade100,
                                        child: Image.asset(
                                          'assets/images/question.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.help_outline,
                                              size: 40,
                                              color: Colors.grey.shade600,
                                            );
                                          },
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

                // 進捗表示とボトムナビゲーション
                Consumer<StampProvider>(
                  builder: (context, stampProvider, child) {
                    // 実際のスポット数（デモスポット除外）
                    final total = spots.where((spot) => !spot.isDemo).length;
                    final collectedCount = stampProvider.stamps
                        .where((stamp) => !spots.any((spot) => 
                            spot.isDemo && spot.title == stamp.spotTitle))
                        .length;

                    return Column(
                      children: [
                // 進捗バー
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                                  Text(
                                    '取得済み: $collectedCount / $total',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${(collectedCount / total * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                          value: collectedCount / total,
                          backgroundColor: Colors.green.shade100,
                          color: Colors.green,
                          minHeight: 8,
                      ),
                    ],
                  ),
                ),

                // ボトムナビゲーション
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
                        Navigator.pushNamed(context, '/');
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/map');
                        break;
                      case 2:
                        Navigator.pushNamed(context, '/ar');
                        break;
                      case 4:
                        Navigator.pushNamed(context, '/profile');
                        break;
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
      ),
    );
  }

  void _showStampDetail(BuildContext context, Stamp stamp) {
    // スタンプに対応するスポット情報を取得
    final spot = spots.firstWhere(
      (spot) => spot.title == stamp.spotTitle,
      orElse: () => spots.where((spot) => !spot.isDemo).first,
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.green.shade100,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: Colors.green.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // スポット情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // デモスポット判定
                    if (spots.any((spot) => spot.isDemo && spot.title == stamp.spotTitle)) ...[
                      Icon(
                        Icons.science,
                        size: 20,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        stamp.spotTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stamp.spotLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
                      const Text(
                        '取得日時',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stamp.collectedAt.year}年${stamp.collectedAt.month}月${stamp.collectedAt.day}日 '
                        '${stamp.collectedAt.hour.toString().padLeft(2, '0')}:${stamp.collectedAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // 閉じるボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  void _showUncollectedSpotDetail(BuildContext context, spot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.help_outline,
                            size: 50,
                            color: Colors.grey.shade600,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // スポット情報
                Text(
                  spot.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  spot.location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
                      Icon(
                        Icons.location_on,
                        size: 32,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'スタンプ未取得',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'このスポットを訪れて\nスタンプを取得しましょう！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
                          Navigator.pushNamed(context, '/map');
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('マップで確認'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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

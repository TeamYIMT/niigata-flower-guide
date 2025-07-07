import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spot.dart';
import '../providers/stamp_provider.dart';
import 'stamp_collection_button.dart';

class NearbySpotsWidget extends StatefulWidget {
  const NearbySpotsWidget({super.key});

  @override
  State<NearbySpotsWidget> createState() => _NearbySpotsWidgetState();
}

class _NearbySpotsWidgetState extends State<NearbySpotsWidget> {
  @override
  void initState() {
    super.initState();
    // 初回の位置情報取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StampProvider>().updateCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StampProvider>(
      builder: (context, stampProvider, child) {
        if (stampProvider.isLoadingLocation) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('位置情報を取得中...'),
                ],
              ),
            ),
          );
        }

        if (stampProvider.nearbySpots.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '近くにスタンプ取得可能なスポットはありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'スポットから100m以内に近づくとスタンプを取得できます',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => stampProvider.updateCurrentPosition(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('位置情報を更新'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '近くのスポット',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => stampProvider.updateCurrentPosition(),
                      icon: const Icon(Icons.refresh),
                      tooltip: '位置情報を更新',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...stampProvider.nearbySpots.map((nearbySpot) {
                  final spot = nearbySpot['spot'] as Spot;
                  final distance = nearbySpot['distance'] as double;
                  final isCollected = stampProvider.isCollected(spot.title);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isCollected ? Colors.grey[300]! : Colors.green[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isCollected ? Colors.grey[50] : Colors.green[50],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      spot.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      spot.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isCollected ? Colors.grey : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCollected ? Icons.check : Icons.location_on,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isCollected ? '取得済み' : '${distance.round()}m',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!isCollected) ...[
                            const SizedBox(height: 12),
                            StampCollectionButton(
                              spot: spot,
                              onSuccess: () {
                                // 成功後の処理があれば追加
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
} 
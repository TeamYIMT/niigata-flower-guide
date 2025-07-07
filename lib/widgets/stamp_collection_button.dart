import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spot.dart';
import '../providers/stamp_provider.dart';

class StampCollectionButton extends StatelessWidget {
  final Spot spot;
  final VoidCallback? onSuccess;

  const StampCollectionButton({
    super.key,
    required this.spot,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StampProvider>(
      builder: (context, stampProvider, child) {
        // 取得済みかチェック
        bool isCollected = stampProvider.isCollected(spot.title);
        
        // 範囲内にあるかチェック
        bool isInRange = stampProvider.isSpotInRange(spot);
        
        // 距離を取得
        double? distance = stampProvider.getDistanceToSpot(spot);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 距離表示
            if (distance != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isInRange ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isInRange ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: isInRange ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${distance.round()}m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isInRange ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            
            // スタンプ取得ボタン
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _getButtonAction(context, stampProvider, isCollected, isInRange),
                icon: _getButtonIcon(isCollected, isInRange, stampProvider.isLoading),
                label: Text(
                  _getButtonText(isCollected, isInRange),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(isCollected, isInRange),
                  foregroundColor: Colors.white,
                  elevation: isCollected ? 0 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            
            // エラーメッセージ表示
            if (stampProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stampProvider.errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => stampProvider.clearError(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            
            // 位置情報更新ボタン
            if (!isInRange && !isCollected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: stampProvider.isLoadingLocation
                      ? null
                      : () => stampProvider.updateCurrentPosition(),
                  icon: stampProvider.isLoadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    stampProvider.isLoadingLocation ? '位置情報を取得中...' : '位置情報を更新',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ボタンのアクション
  VoidCallback? _getButtonAction(
    BuildContext context,
    StampProvider stampProvider,
    bool isCollected,
    bool isInRange,
  ) {
    if (isCollected || stampProvider.isLoading) {
      return null;
    }

    if (!isInRange) {
      return () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スポットの近くに移動してください'),
            backgroundColor: Colors.orange,
          ),
        );
      };
    }

    return () async {
      bool success = await stampProvider.collectStamp(spot);
      if (success) {
        onSuccess?.call();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「${spot.title}」のスタンプを取得しました！'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'コレクションを見る',
                textColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/collection'),
              ),
            ),
          );
        }
      }
    };
  }

  // ボタンのアイコン
  Widget _getButtonIcon(bool isCollected, bool isInRange, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isCollected) {
      return const Icon(Icons.check_circle);
    }

    if (!isInRange) {
      return const Icon(Icons.location_off);
    }

    return const Icon(Icons.star);
  }

  // ボタンのテキスト
  String _getButtonText(bool isCollected, bool isInRange) {
    if (isCollected) {
      return '取得済み';
    }

    if (!isInRange) {
      return 'スポットに近づいてください';
    }

    return 'スタンプを取得';
  }

  // ボタンの色
  Color _getButtonColor(bool isCollected, bool isInRange) {
    if (isCollected) {
      return Colors.grey;
    }

    if (!isInRange) {
      return Colors.orange;
    }

    return Colors.green;
  }
} 
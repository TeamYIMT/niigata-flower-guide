import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spot.dart';
import '../providers/stamp_provider.dart';
import '../screens/stamps_collection_screen.dart';

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
                icon: _getButtonIcon(isCollected, isInRange, stampProvider.isSpotLoading(spot.title)),
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
    // スポット個別のロード状態をチェック
    if (isCollected || stampProvider.isSpotLoading(spot.title)) {
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
      print('📝 スタンプ取得ボタンが押されました: ${spot.title}');
      bool success = await stampProvider.collectStamp(spot);
      print('🎯 collectStamp結果: $success (${spot.title})');
      
      if (success) {
        print('✅ スタンプ取得成功!');
        onSuccess?.call();
        
        if (context.mounted) {
          // ダイアログが開いている場合は先に閉じる
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          // より確実なアプローチ: コンテキストを保存してから遅延実行
          final navigationContext = context;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「${spot.title}」のスタンプを取得しました！'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'コレクションを見る',
                textColor: Colors.white,
                onPressed: () {
                  print('🔄 コレクション画面への遷移を開始します');
                  // SnackBarを先に閉じる
                  ScaffoldMessenger.of(navigationContext).hideCurrentSnackBar();
                  
                  // 少し待ってから確実にナビゲーション
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (navigationContext.mounted) {
                      try {
                        // 最も確実な方法: main.dartで定義されたルートを使用
                        Navigator.of(navigationContext, rootNavigator: true).pushNamed('/collection');
                        print('✅ コレクション画面への遷移成功');
                      } catch (e) {
                        print('💥 ルート遷移でエラー: $e');
                        // 代替: 直接画面を開く
                        Navigator.of(navigationContext).push(
                          MaterialPageRoute(
                            builder: (context) => const StampCollectionScreen(),
                          ),
                        );
                        print('✅ 直接遷移で成功');
                      }
                    }
                  });
                },
              ),
            ),
          );
        }
      } else {
        print('❌ スタンプ取得失敗: ${spot.title}');
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

    if (spot.isDemo) {
      return const Icon(Icons.science);
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

    if (spot.isDemo) {
      return 'デモスタンプを取得';
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

    if (spot.isDemo) {
      return Colors.orange;
    }

    if (!isInRange) {
      return Colors.orange;
    }

    return Colors.green;
  }
} 
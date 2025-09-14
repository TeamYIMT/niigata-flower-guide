import 'package:flutter/material.dart';
import '../common/video_source.dart';
import 'ar_preview_sheet.dart';

class FlowerVideoRegistry {
  static final Map<String, VideoSource> _map = {
    // アジサイ
    'hydrangea': const VideoSource.asset('assets/videos/hydrangea.mp4'),
    // チューリップ
    'tulip': const VideoSource.asset('assets/videos/tulip.mp4'),
    // 桜
    'sakura': const VideoSource.asset('assets/videos/sakura.mp4'),
    // 菜の花
    'rapeblossoms': const VideoSource.asset('assets/videos/rapeblossoms.mp4'),
    // ハス
    'lotus': const VideoSource.asset('assets/videos/lotus.mp4'),
  };

  static VideoSource? resolve(String flowerId) => _map[flowerId];
}

class ArPreviewLauncher {
  final void Function(String message)? onMissingVideo;
  final Color? saveButtonColor;
  final Color? saveButtonForegroundColor;

  ArPreviewLauncher({this.onMissingVideo, this.saveButtonColor = const Color(0xFF4CAF50), this.saveButtonForegroundColor = Colors.white});

  Future<void> show(BuildContext context, {required String flowerId}) async {
    final src = FlowerVideoRegistry.resolve(flowerId);
    if (src == null) {
      onMissingVideo?.call('このスポットにはプレビュー動画が未登録です。');
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ArPreviewSheet(
        source: src,
        showStartButton: false,
        saveButtonColor: saveButtonColor ?? Colors.black54,
        saveButtonForegroundColor: saveButtonForegroundColor ?? Colors.white,
      ),
    );
  }

  Future<void> pickAndShow(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      builder: (ctx) {
        Widget buildItem(String id, String label, IconData icon, {required bool enabled}) {
          return ListTile(
            enabled: enabled,
            leading: Icon(icon, color: enabled ? null : Colors.grey),
            title: Text(label, style: enabled ? null : const TextStyle(color: Colors.grey)),
            onTap: enabled ? () => Navigator.of(ctx).pop(id) : null,
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('花を選択', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              buildItem('tulip', 'チューリップ', Icons.local_florist, enabled: true),
              buildItem('hydrangea', 'アジサイ', Icons.local_florist, enabled: false),
              buildItem('sakura', '桜', Icons.local_florist, enabled: false),
              buildItem('rapeblossoms', '菜の花', Icons.local_florist, enabled: false),
              buildItem('lotus', 'ハス', Icons.local_florist, enabled: false),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    await show(context, flowerId: selected);
  }
}



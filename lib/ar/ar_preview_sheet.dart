import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../common/video_source.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ArPreviewSheet extends StatefulWidget {
  final VideoSource source;
  final String title;
  final bool showStartButton;
  final VoidCallback? onStartAr;
  final Color saveButtonColor;
  final Color saveButtonForegroundColor;

  const ArPreviewSheet({
    super.key,
    required this.source,
    this.title = 'ARプレビュー',
    this.showStartButton = false,
    this.onStartAr,
    this.saveButtonColor = const Color(0xFF4CAF50),
    this.saveButtonForegroundColor = Colors.white,
  });

  @override
  State<ArPreviewSheet> createState() => _ArPreviewSheetState();
}

class _ArPreviewSheetState extends State<ArPreviewSheet> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = switch (widget.source.kind) {
      VideoKind.asset => VideoPlayerController.asset(widget.source.pathOrUrl),
      VideoKind.network => VideoPlayerController.networkUrl(Uri.parse(widget.source.pathOrUrl)),
    };
    _controller
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _ready ? _controller.value.aspectRatio : 16 / 9;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: ratio,
                  child: _ready
                      ? VideoPlayer(_controller)
                      : const Center(child: CircularProgressIndicator()),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.saveButtonColor,
                      foregroundColor: widget.saveButtonForegroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(_saving ? '保存中…' : '保存する', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            try {
                              switch (widget.source.kind) {
                                case VideoKind.asset:
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('アセット動画の保存は現在未対応です')),
                                  );
                                  break;
                                case VideoKind.network:
                                  final ok = await GallerySaver.saveVideo(widget.source.pathOrUrl);
                                  if (ok == true) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('保存しました')),
                                    );
                                  } else {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('保存に失敗しました')),
                                    );
                                  }
                                  break;
                              }
                            } finally {
                              if (mounted) setState(() => _saving = false);
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('閉じる'),
                ),
                const Spacer(),
                if (widget.showStartButton && widget.onStartAr != null)
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                      widget.onStartAr!.call();
                    },
                    child: const Text('ARを起動'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



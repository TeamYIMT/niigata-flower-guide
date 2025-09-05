import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UnityWebViewPage extends StatefulWidget {
  const UnityWebViewPage({super.key});

  @override
  State<UnityWebViewPage> createState() => _UnityWebViewPageState();
}

class _UnityWebViewPageState extends State<UnityWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  static const String unityUrl = 'https://ishikawa-y123.github.io/Ajisai-webgl/';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();

    if (!kIsWeb) {
      // モバイルのみ: JS有効化 + NavigationDelegate
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() => _loading = false);
            },
            onWebResourceError: (_) {
              if (!mounted) return;
              setState(() => _loading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(unityUrl));
    } else {
      // Web: NavigationDelegateは使わない（未実装エラー回避）
      _controller.loadRequest(Uri.parse(unityUrl));
      // 簡易ローディング解除（onPageFinishedを使わないため）
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity WebGL'),
        actions: [
          IconButton(
            tooltip: '新しいタブで開く',
            onPressed: () => launchUrl(
              Uri.parse(unityUrl),
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_blank',
            ),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

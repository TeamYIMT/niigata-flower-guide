import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityHostPage extends StatefulWidget {
  const UnityHostPage({super.key});
  @override
  State<UnityHostPage> createState() => _UnityHostPageState();
}

class _UnityHostPageState extends State<UnityHostPage> {
  UnityWidgetController? _unity;

  void _onCreated(UnityWidgetController c) => _unity = c;

  void _onMessage(dynamic m) {
    debugPrint('Unity→Flutter: $m');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$m')));
  }

  Future<void> _send() async {
    await _unity?.postMessage('FlutterBridge', 'OnFlutterMessage', '{"cmd":"ping"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter ⇄ Unity (AR)')),
      body: UnityWidget(onUnityCreated: _onCreated, onUnityMessage: _onMessage),
      floatingActionButton: FloatingActionButton(onPressed: _send, child: const Icon(Icons.send)),
    );
  }
}

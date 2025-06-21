import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityArScreen extends StatefulWidget {
  const UnityArScreen({Key? key}) : super(key: key);

  @override
  State<UnityArScreen> createState() => _UnityArScreenState();
}

class _UnityArScreenState extends State<UnityArScreen> {
  late UnityWidgetController _controller;

  void _onUnityCreated(UnityWidgetController controller) {
    _controller = controller;
  }

  void _sendMessage() {
    _controller.postMessage('FlutterReceiver', 'OnMessage', 'Hello from Flutter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR View')),
      body: UnityWidget(onUnityCreated: _onUnityCreated),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        child: const Icon(Icons.send),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityArScreen extends StatefulWidget {
  const UnityArScreen({Key? key}) : super(key: key);

  @override
  State<UnityArScreen> createState() => _UnityArScreenState();
}

class _UnityArScreenState extends State<UnityArScreen> {
  late UnityWidgetController _controller;
  bool _isUnityReady = false;
  String _lastMessage = '';

  void _onUnityCreated(UnityWidgetController controller) {
    setState(() {
      _controller = controller;
      _isUnityReady = true;
    });
    print('Unity is ready!');
  }

  void _onUnityMessage(dynamic message) {
    setState(() {
      _lastMessage = message.toString();
    });
    print('Received message from Unity: $message');
  }

  void _sendMessage() {
    if (_isUnityReady) {
      _controller.postMessage('FlutterReceiver', 'OnMessage', 'Hello from Flutter!');
      print('Message sent to Unity');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unity is not ready yet')),
      );
    }
  }

  void _loadScene(String sceneName) {
    if (_isUnityReady) {
      _controller.postMessage(
        'GameManager',
        'LoadScene',
        sceneName,
      );
      print('Loading scene: $sceneName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR カメラ'),
        backgroundColor: const Color(0xFF3E5C40),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Unityウィジェット
          Expanded(
            child: UnityWidget(
              onUnityCreated: _onUnityCreated,
              onUnityMessage: _onUnityMessage,
            ),
          ),
          // コントロールパネル
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // ステータス表示
                Row(
                  children: [
                    Icon(
                      _isUnityReady ? Icons.check_circle : Icons.error,
                      color: _isUnityReady ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isUnityReady ? 'Unity Ready' : 'Unity Loading...',
                      style: TextStyle(
                        color: _isUnityReady ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 受信メッセージ表示
                if (_lastMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Unity: $_lastMessage',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                // ボタン群
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isUnityReady ? _sendMessage : null,
                      child: const Text('メッセージ送信'),
                    ),
                    ElevatedButton(
                      onPressed: _isUnityReady ? () => _loadScene('ARDemo') : null,
                      child: const Text('ARシーン読み込み'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
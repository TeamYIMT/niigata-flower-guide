import 'package:flutter/material.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityArScreen extends StatefulWidget {
  const UnityArScreen({Key? key}) : super(key: key);

  @override
  State<UnityArScreen> createState() => _UnityArScreenState();
}

class _UnityArScreenState extends State<UnityArScreen> {
  // late UnityWidgetController _controller;
  // bool _isUnityReady = false;
  // String _lastMessage = '';

  // void _onUnityCreated(UnityWidgetController controller) {
  //   setState(() {
  //     _controller = controller;
  //     _isUnityReady = true;
  //   });
  //   print('Unity is ready!');
  // }

  // void _onUnityMessage(dynamic message) {
  //   setState(() {
  //     _lastMessage = message.toString();
  //   });
  //   print('Received message from Unity: $message');
  // }

  // void _sendMessage() {
  //   if (_isUnityReady) {
  //     _controller.postMessage('FlutterReceiver', 'OnMessage', 'Hello from Flutter!');
  //     print('Message sent to Unity');
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Unity is not ready yet')),
  //     );
  //   }
  // }

  // void _loadScene(String sceneName) {
  //   if (_isUnityReady) {
  //     _controller.loadScene(sceneName);
  //     print('Loading scene: $sceneName');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR カメラ'),
        backgroundColor: const Color(0xFF3E5C40),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 100,
              color: Color(0xFF3E5C40),
            ),
            const SizedBox(height: 20),
            const Text(
              'AR カメラ機能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E5C40),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unity統合が一時的に無効になっています',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unity統合を有効にするには、UnityプロジェクトからAndroidライブラリをエクスポートしてください'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E5C40),
                foregroundColor: Colors.white,
              ),
              child: const Text('詳細情報'),
            ),
          ],
        ),
      ),
    );
  }
}

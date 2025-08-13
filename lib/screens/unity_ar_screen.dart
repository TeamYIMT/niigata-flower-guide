import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityARScreen extends StatefulWidget {
  @override
  _UnityARScreenState createState() => _UnityARScreenState();
}

class _UnityARScreenState extends State<UnityARScreen> {
  UnityWidgetController? _controller;
  bool _isUnityReady = false;
  String _lastMessage = '';
  bool _hasError = false;
  String _errorMessage = '';

  void _onUnityCreated(UnityWidgetController controller) {
    setState(() {
      _controller = controller;
      _isUnityReady = true;
      _hasError = false;
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
    if (_isUnityReady && _controller != null) {
      try {
        _controller!.postMessage('FlutterReceiver', 'OnMessage', 'Hello from Flutter!');
        print('Message sent to Unity');
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to send message: $e';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unity is not ready yet')),
      );
    }
  }

  void _loadScene(String sceneName) {
    if (_isUnityReady && _controller != null) {
      try {
        _controller!.postMessage('GameManager', 'LoadScene', sceneName);
        print('Loading scene: $sceneName');
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load scene: $e';
        });
      }
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
            child: _hasError
                ? _buildErrorWidget()
                : _buildUnityWidget(),
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
                      _hasError 
                          ? Icons.error 
                          : _isUnityReady 
                              ? Icons.check_circle 
                              : Icons.hourglass_empty,
                      color: _hasError 
                          ? Colors.red 
                          : _isUnityReady 
                              ? Colors.green 
                              : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasError 
                          ? 'Unity Error' 
                          : _isUnityReady 
                              ? 'Unity Ready' 
                              : 'Unity Loading...',
                      style: TextStyle(
                        color: _hasError 
                            ? Colors.red 
                            : _isUnityReady 
                                ? Colors.green 
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // エラーメッセージ表示
                if (_hasError)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                // 受信メッセージ表示
                if (_lastMessage.isNotEmpty && !_hasError)
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
                      onPressed: _isUnityReady && !_hasError ? _sendMessage : null,
                      child: const Text('メッセージ送信'),
                    ),
                    ElevatedButton(
                      onPressed: _isUnityReady && !_hasError ? () => _loadScene('ARDemo') : null,
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

  Widget _buildUnityWidget() {
    return UnityWidget(
      onUnityCreated: _onUnityCreated,
      onUnityMessage: _onUnityMessage,
      onUnitySceneLoaded: (SceneLoaded? scene) {
        if (scene != null) {
          print('Scene loaded: ${scene.name}');
        }
      },
      onUnityUnloaded: () {
        print('Unity unloaded');
        setState(() {
          _isUnityReady = false;
          _controller = null;
        });
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'Unity統合エラー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'UnityFrameworkの設定に問題があります。\n開発者に連絡してください。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityArScreen extends StatelessWidget {
  const UnityArScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR カメラ'),
        backgroundColor: const Color(0xFF3E5C40),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Unity連携は一時的に無効化されています',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

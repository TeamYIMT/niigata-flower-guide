import 'package:flutter/material.dart';

class UnityArScreen extends StatelessWidget {
  const UnityArScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR カメラ')),
      body: const Center(
        child: Text('WebではUnity ARは利用できません'),
      ),
    );
  }
} 
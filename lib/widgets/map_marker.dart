import 'package:flutter/material.dart';

class MapMarker extends StatelessWidget {
  const MapMarker({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF56C0B3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.local_florist, color: Colors.white, size: 16),
        ),
      );
} 
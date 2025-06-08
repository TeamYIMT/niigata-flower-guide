import 'package:flutter/material.dart';

class IconTile extends StatelessWidget {
  final String icon, label;
  final Color bgColor;
  const IconTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: () {
        // TODO: Navigator.pushNamed(...) など
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/$icon', width: 48, height: 48),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

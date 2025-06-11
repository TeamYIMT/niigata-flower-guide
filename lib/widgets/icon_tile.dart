import 'package:flutter/material.dart';

class IconTile extends StatelessWidget {
  final String icon, label;
  final Color bgColor;
  final double iconSize;  // 追加
  final double fontSize;  // 追加
  final double padding;   // 追加
  final VoidCallback? onTap;

  const IconTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.bgColor,
    this.iconSize = 48,
    this.fontSize = 16,
    this.padding = 8,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(padding),
      ),
      onPressed: onTap, // 画面遷移などはココに実装
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$icon',
            width: iconSize,
            height: iconSize,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

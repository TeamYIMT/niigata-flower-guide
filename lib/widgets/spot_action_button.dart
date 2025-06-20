import 'package:flutter/material.dart';

class SpotActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const SpotActionButton({required this.icon, required this.label, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Color(0xFF3E5C40)),
          minimumSize: const Size(72, 64),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3E5C40)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF3E5C40), fontSize: 12)),
          ],
        ),
      );
} 
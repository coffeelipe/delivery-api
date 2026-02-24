import 'package:flutter/material.dart';

class MarkAsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;
  final IconData icon;
  final Color color;
  const MarkAsButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: label,
      icon: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

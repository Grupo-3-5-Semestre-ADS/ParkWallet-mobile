import 'package:flutter/material.dart';

enum IconPosition { start, end }
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final IconPosition iconPosition;
  final double? width; // Agora opcional
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF14517E),
    this.textColor = Colors.white,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      if (icon != null && iconPosition == IconPosition.start)
        Icon(icon, color: textColor, size: 18),
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (icon != null && iconPosition == IconPosition.end)
        Icon(icon, color: textColor, size: 18),
    ];

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: content
            .map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: e,
        ))
            .toList(),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}

import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final bool isBold;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  const CustomHeading({
    Key? key,
    required this.text,
    this.fontSize = 24.0,
    this.color,
    this.isBold = true,
    this.textAlign = TextAlign.left,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingColor = color ?? theme.colorScheme.onBackground;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: headingColor,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: textAlign,
          ),
        ),
        if (showDivider)
          Container(
            height: 2,
            width: 60,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.primary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
} 
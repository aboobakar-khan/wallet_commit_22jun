import 'package:flutter/material.dart';

import '../../core/core.dart';

/// An Arabic spiritual phrase — Amiri, shaped, always rendered RTL regardless of
/// the app's current direction (Arabic script reads right-to-left).
class ArabicPhrase extends StatelessWidget {
  const ArabicPhrase(this.text, {super.key, this.color, this.fontSize});
  final String text;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final style = context.text.arabic;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style.copyWith(
          color: color ?? style.color,
          fontSize: fontSize ?? style.fontSize,
        ),
      ),
    );
  }
}

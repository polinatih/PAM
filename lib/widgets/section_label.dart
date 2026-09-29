import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Text(
      text.toUpperCase(),
      style: color == null ? style : style?.copyWith(color: color),
    );
  }
}
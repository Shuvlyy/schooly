import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final Text text;
  final String? tooltip;
  final Function()? onTap;

  const ClickableText({
    super.key,
    required this.text,
    this.tooltip,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(5.0),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Tooltip(
          message: tooltip ?? "",
          child: text
        ),
      ),
    );
  }
}
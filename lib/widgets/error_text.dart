import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({
    super.key,
    required this.text
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w500,
        fontSize: 18.0
      ),
      textAlign: TextAlign.center,
    );
  }
}
import 'package:flutter/material.dart';

class RegisterPageLayout extends StatelessWidget {
  const RegisterPageLayout({
    super.key,
    this.body,
    this.alignment = MainAxisAlignment.start,
    this.autoSpacing = true,
    this.spacing = 20.0
  });

  final List<Widget>? body;
  final MainAxisAlignment alignment;
  final bool autoSpacing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    
    List<Widget> widgets = body ?? [];

    if (autoSpacing && body != null) {
      for (int k = 0; k < widgets.length; k += 2) {
        widgets.insert(
          k + 1,
          SizedBox(height: spacing)
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: alignment,
        children: widgets
      )
    );
  }
}
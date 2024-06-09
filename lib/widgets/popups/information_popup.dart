import 'package:flutter/material.dart';
import 'package:schooly/widgets/popups/spopup.dart';

class InformationPopup extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String content;

  const InformationPopup({
    super.key,

    this.icon = Icons.info_rounded,
    this.iconBackgroundColor = Colors.cyan,
    this.title = 'Information',
    required this.content
  });

  @override
  Widget build(BuildContext context) {
    return SPopup(
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      title: title, 
      content: content,
      confirmButtonTitle: 'OK',
      showCancelButton: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:schooly/dialogs/sdialog.dart';

class SConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final Color? iconBackgroundColor;
  final String title;
  final String content;
  final String confirmButtonTitle;
  final String? cancelButtonTitle;
  final Function() onConfirm;

  const SConfirmationDialog({
    super.key,

    required this.icon,
    this.iconBackgroundColor,
    required this.title,
    required this.content,
    this.confirmButtonTitle = 'Oui',
    this.cancelButtonTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SDialog(
      icon: icon, 
      iconBackgroundColor: iconBackgroundColor,
      title: title, 
      content: content,
      confirmButtonTitle: confirmButtonTitle,
      cancelButtonTitle: cancelButtonTitle ?? '',
      onConfirm: onConfirm
    );
  }
}
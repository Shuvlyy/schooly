import 'package:flutter/material.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/widgets/popups/spopup.dart';

class ErrorPopup extends StatelessWidget {
  final SStatus error;
  final Function()? onConfirm;

  const ErrorPopup({
    super.key,
    required this.error,
    this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return SPopup(
      icon: Icons.close_rounded,
      iconBackgroundColor: Colors.red,
      title: 'Erreur', 
      content: error.message,
      subContent: "${error.hex} : ${error.string}",
      confirmButtonTitle: 'OK',
      showCancelButton: false,
      confirmButtonColor: Colors.red,
      onConfirm: onConfirm,
    );
  }
}
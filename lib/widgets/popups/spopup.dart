import 'package:flutter/material.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';

class SPopup extends StatelessWidget {
  const SPopup({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.content,
    this.subContent,
    this.confirmButtonTitle = 'Confirmer',
    this.cancelButtonTitle = 'Annuler',
    this.confirmButtonColor,
    this.showCancelButton = true,
    this.onConfirm,
    this.onCancel
  });

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String content;
  final String? subContent;
  final String confirmButtonTitle;
  final String cancelButtonTitle;
  final Color? confirmButtonColor;
  final bool showCancelButton;
  final Function? onConfirm;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.symmetric(vertical: 20.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      actionsPadding: const EdgeInsets.all(20.0),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40))
      ),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ... {
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(12.5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: iconBackgroundColor ?? Theme.of(context).primaryColor,
                    blurRadius: 4,
                    offset: Offset.zero
                  )
                ]
              ),
              child: Center(
                child: Icon(
                  icon!,
                  color: iconColor ?? Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 15.0)
          },

          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)
          )
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          if (subContent != null) ... {
            const SizedBox(height: 20.0),
            Text(
              subContent!,
              style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            )
          }
        ]
      ),

      actions: <SButton>[
        if (showCancelButton) ... {
          SButton(
            title: cancelButtonTitle,
            onTap: 
              onCancel != null 
              ? () => onCancel!()
              : () => closePopup(context)
          )
        },
        SButton(
          title: confirmButtonTitle,
          backgroundColor: confirmButtonColor,
          onTap: 
            onConfirm != null 
            ? () => onConfirm!()
            : () => closePopup(context)
        )
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

void closePopup(BuildContext context) {
  Navigator.of(context).pop();
}
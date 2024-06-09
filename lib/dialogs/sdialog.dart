import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/widgets/buttons/dialog_button.dart';

class SDialog extends StatelessWidget {
  final IconData icon;
  final Color? iconBackgroundColor;
  final String title;
  final String content;
  final String? subContent;
  final String confirmButtonTitle;
  final String cancelButtonTitle;
  final Function()? onConfirm;
  final bool showCancelButton;

  const SDialog({
    super.key,
    required this.icon,
    this.iconBackgroundColor,
    required this.title,
    required this.content,
    this.subContent,
    this.confirmButtonTitle = 'Confirmer',
    this.cancelButtonTitle = 'Annuler',
    this.onConfirm,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBgColor = iconBackgroundColor ?? Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0)
      ),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: iconBgColor,
                  blurRadius: 4,
                )
              ]
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white
              ),
            ),
          ),

          const SizedBox(width: 15.0),
          
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
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
            Text(
              subContent!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
          }
        ],
      ),

      actionsAlignment: MainAxisAlignment.center,
      
      actions: <Flex>[
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showCancelButton) ... {
              DialogButton(
                text: cancelButtonTitle,
                style: DialogButtonStyle.secondary,
                onTap: () {
                  context.pop();
                },
              )
            } else ... {
              Expanded(
                child: Container(),
              )
            },

            DialogButton( 
              text: confirmButtonTitle, 
              style: DialogButtonStyle.primary,
              onTap: () {
                if (onConfirm != null) {
                  onConfirm!();
                }
          
                context.pop();
              },
            )
          ],
        )
      ],
    );
  }
}
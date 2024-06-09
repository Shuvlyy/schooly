// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:schooly/widgets/buttons/dialog_button.dart';

class ModalBottomSheetLayout extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? description;
  final bool showActions;

  final List<Widget> widgets;
  
  final Function()? onConfirm;

  const ModalBottomSheetLayout({
    super.key,

    required this.icon,
    this.iconBackgroundColor = Colors.grey,
    required this.title,
    this.description,
    this.showActions = true,

    required this.widgets,

    this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          blurRadius: 4.0,
                          color: iconBackgroundColor,
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26.0,
                    ),
                  ),
  
                  const SizedBox(width: 15.0),
  
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                      // ?.copyWith(
                      //   color: Colors.white
                      // ),
                  ),
                ],
              ),
  
              if (description != null) ... {
                const SizedBox(height: 10.0),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.normal
                    )
                )
              },
  
              const SizedBox(height: 20.0),
  
              Column(children: widgets),
  
              const SizedBox(height: 20.0),
  
              if (showActions) ... {
                Row(
                  children: <Widget>[
                    const SizedBox(width: 20.0),
                    DialogButton(
                      style: DialogButtonStyle.secondary, 
                      text: 'Annuler', 
                      onTap: () => Navigator.of(context).pop()
                    ),
                    const SizedBox(width: 20.0),
                    DialogButton(
                      style: DialogButtonStyle.primary, 
                      text: 'Confirmer', 
                      onTap: () async {
                        if (onConfirm != null) {
                          final dynamic result = await onConfirm!();

                          if (result is bool && result == false) return;
                        }

                        Navigator.of(context).pop();
                      }
                    ),
                    const SizedBox(width: 20.0)
                  ],
                )
              }
            ],
          ),
        )
      ],
    );
  }
}
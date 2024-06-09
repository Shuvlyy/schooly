import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/models/user/privacysettings.dart';

class RadioButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Object value;
  final Object groupValue;
  final Function(Object?) onChanged;

  const RadioButton({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    required this.value,
    required this.groupValue,
    required this.onChanged
  });

  static RadioButton fromPrivacySetting({
    required SPrivacySetting privacySetting,
    required Object groupValue,
    required Function(Object?) onChanged
  }) {
    return RadioButton(
      title: privacySetting.displayName, 
      value: privacySetting, 
      icon: privacySetting.icon,
      iconBackgroundColor: privacySetting.color,
      groupValue: groupValue, 
      onChanged: onChanged
    );
  }

  static RadioButton fromPrivacyLevel({
    required SPrivacyLevel privacyLevel,
    required Object groupValue,
    required Function(Object?) onChanged
  }) {
    return RadioButton(
      title: privacyLevel.displayName, 
      value: privacyLevel, 
      icon: privacyLevel.icon,
      iconBackgroundColor: privacyLevel.color,
      groupValue: groupValue, 
      onChanged: onChanged
    );
  }

  static RadioButton fromBool({
    required bool value,
    required Object groupValue,
    required Function(Object?) onChanged
  }) {
    return RadioButton(
      title: value ? 'Oui' : 'Non', 
      value: value, 
      icon: value ? Icons.done_rounded : Icons.close_rounded,
      iconBackgroundColor: value ? const Color.fromRGBO(119, 221, 118, 1) : const Color.fromRGBO(255, 105, 98, 1),
      groupValue: groupValue, 
      onChanged: onChanged
    );
  }

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0)
      ),
      activeColor: Theme.of(context).primaryColor,
      title: Row(
        children: <Widget>[
          if (icon != null) ... {
            Container(
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 4.0,
                    color: iconBackgroundColor ?? Colors.black,
                  )
                ]
              ),
              padding: const EdgeInsets.all(7.5),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26.0,
              ),
            ),

            const SizedBox(width: 15.0)
          },
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Text>[
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge
              ),

              if (subtitle != null) ... {
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SColors.getGreyscaleColor(context)
                  )
                )
              }
            ],
          )
        ],
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
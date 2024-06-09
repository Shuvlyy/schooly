import 'package:flutter/material.dart';

class SBadge {
  int zIndex;
  String name;
  String displayName;
  String hexColor;
  IconData? icon;

  SBadge({
    this.zIndex = 0,
    this.name = '',
    this.displayName = '',
    this.hexColor = '#808080',
    this.icon
  });

  static SBadge fromName(String name) {
    return SBadge.fromModel(
      SBadgeModel.values.firstWhere(
        (badge) => badge.name == name, 
        orElse: () => SBadgeModel.unknown
      )
    );
  }

  static SBadge fromModel(SBadgeModel model) {
    switch (model) {
      case SBadgeModel.staff:
        return SBadge(
          zIndex: 100,
          name: 'staff',
          displayName: 'Staff',
          hexColor: '#d35e6f',
          icon: Icons.security_rounded
        );
      case SBadgeModel.betaTest:
        return SBadge(
          zIndex: 99,
          name: 'betaTest',
          displayName: 'Bêta Testeur',
          hexColor: '#00a706',
          icon: Icons.code_rounded
        );
      case SBadgeModel.alphaMember:
        return SBadge(
          zIndex: 98,
          name: 'alphaMember',
          displayName: 'OG',
          hexColor: '#58009c',
          icon: Icons.access_time_rounded
        );
      case SBadgeModel.unknown:
        return SBadge(
          zIndex: 0,
          displayName: 'm̷͓̓i̸̛̓s̸̊̔s̸̼̀i̵͐̅n̶͛̋ḡ̵no',
          hexColor: '#b762c1',
          icon: Icons.question_mark_rounded
        );
      default:
        return SBadge();
    }
  }

  Widget get widget {
    return SBadgeWidget.fromBadge(this);
  }
}

class SBadgeWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Function()? onTap;

  const SBadgeWidget({
    super.key,

    required this.icon,
    required this.iconColor,
    required this.title,
    this.onTap
  });

  static SBadgeWidget fromBadge(SBadge badge) {
    return SBadgeWidget(
      icon: badge.icon ?? Icons.question_mark_rounded,
      iconColor: Color(int.parse("0xff${badge.hexColor.replaceAll('#', '')}")),
      title: badge.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(15.0);

    return SizedBox(
      width: 42.0,
      height: 42.0,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          elevation: 4.0,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onTap ?? () {},
            borderRadius: borderRadius,
            child: Tooltip(
              message: title,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension SBadgeExtension on SBadge {
  
}

enum SBadgeModel {
  staff,
  betaTest,
  alphaMember,
  unknown
}
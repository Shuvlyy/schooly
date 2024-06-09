import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/models/user/privacysettings.dart';
// import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/widgets/popups/modal_bottom_sheet_layout.dart';
import 'package:schooly/widgets/radio_button.dart';
import 'package:schooly/widgets/separator.dart';

class DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? description;
  final bool transparentBackground;

  final Object value;

  final Function() onTap;

  const DropdownTile({
    super.key,

    required this.icon,
    this.iconBackgroundColor = Colors.grey,
    required this.title,
    this.description,
    this.transparentBackground = false,

    required this.value,

    required this.onTap
  });

  static DropdownTile fromPrivacySetting({
    required BuildContext context,
    required SPrivacy privacySetting,
    bool transparentBackground = false,
    
    List<SPrivacyLevel>? levels,

    Function(
      SPrivacySetting privacySetting,
      SPrivacyLevel? privacyLevel
    )? onConfirm,
  }) {
    final String title = privacySetting.displayName;
    final String description = privacySetting.description;
    final IconData icon = privacySetting.icon;
    final Color color = privacySetting.color;
    String value = privacySetting.privacy.displayName;

    if (privacySetting.level != null) {
      value += ", ${privacySetting.level?.displayName}";
    }

    return DropdownTile(
      title: title,
      description: description,
      icon: icon,
      iconBackgroundColor: color,
      value: value, 
      transparentBackground: transparentBackground,
      onTap: () {
        showModalBottomSheet<dynamic>(
          context: context, 
          isScrollControlled: true,
          builder: (BuildContext context) {
            SPrivacySetting selectedPrivacySetting = privacySetting.privacy;
            SPrivacyLevel? selectedPrivacyLevel;

            if (levels != null) {
              selectedPrivacyLevel = privacySetting.level;
            }

            return StatefulBuilder(
              builder: (
                BuildContext context, 
                StateSetter setModalState
              ) {
                return ModalBottomSheetLayout(
                  title: title,
                  description: description,
                  icon: icon,
                  iconBackgroundColor: color,

                  widgets: <Widget>[
                    for (SPrivacySetting setting in SPrivacySetting.values) ... {
                      RadioButton.fromPrivacySetting(
                        privacySetting: setting, 
                        groupValue: selectedPrivacySetting, 
                        onChanged: (Object? value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedPrivacySetting = value as SPrivacySetting;
                          });
                        }
                      )
                    },

                    if (levels != null) ... [
                      const SizedBox(height: 5.0),

                      const Separator(),
                      
                      const SizedBox(height: 5.0),

                      for (SPrivacyLevel level in levels) ... {
                        RadioButton.fromPrivacyLevel(
                          privacyLevel: level, 
                          groupValue: selectedPrivacyLevel!, 
                          onChanged: (Object? value) {
                            if (value == null) return;

                            setModalState(() {
                              selectedPrivacyLevel = value as SPrivacyLevel;
                            });
                          }
                        )
                      }
                    ]
                  ],

                  onConfirm: () {
                    onConfirm!(
                      selectedPrivacySetting, 
                      selectedPrivacyLevel
                    );
                  },
                );
              }
            );
          }
        );
      }
    );
  }

  static DropdownTile fromBool({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool baseValue,
    bool transparentBackground = false,

    Function(
      bool value
    )? onConfirm,
  }) {
    return DropdownTile(
      title: title,
      description: description,
      icon: icon,
      iconBackgroundColor: color,
      value: baseValue, 
      transparentBackground: transparentBackground,
      onTap: () {
        showModalBottomSheet<dynamic>(
          context: context, 
          isScrollControlled: true,
          builder: (BuildContext context) {
            bool selectedValue = baseValue;

            return StatefulBuilder(
              builder: (
                BuildContext context, 
                StateSetter setModalState
              ) {
                return ModalBottomSheetLayout(
                  title: title,
                  description: description,
                  icon: icon,
                  iconBackgroundColor: color,

                  widgets: <Widget>[
                    for (bool v in [true, false]) ... {
                      RadioButton.fromBool(
                        value: v, 
                        groupValue: selectedValue, 
                        onChanged: (Object? value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedValue = value as bool;
                          });
                        }
                      ),
                    }
                  ],

                  onConfirm: () {
                    onConfirm!(selectedValue);
                  },
                );
              }
            );
          }
        );
      }
    );
  }

  static DropdownTile fromDropdownTileOptions({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required DropdownTileOption baseValue,
    required List<DropdownTileOption> values,
    bool transparentBackground = false,

    Function(
      String value
    )? onConfirm,
  }) {
    return DropdownTile(
      title: title,
      description: description,
      icon: icon,
      iconBackgroundColor: color,
      value: baseValue, 
      transparentBackground: transparentBackground,
      onTap: () {
        showModalBottomSheet<dynamic>(
          context: context, 
          isScrollControlled: true,
          builder: (BuildContext context) {
            String selectedValue = baseValue.name;

            return StatefulBuilder(
              builder: (
                BuildContext context, 
                StateSetter setModalState
              ) {
                return ModalBottomSheetLayout(
                  title: title,
                  description: description,
                  icon: icon,
                  iconBackgroundColor: color,

                  widgets: <Widget>[
                    for (DropdownTileOption opt in values) ... {
                      RadioButton(
                        title: opt.displayName, 
                        subtitle: opt.subtitle,
                        value: opt.name, 
                        icon: opt.icon,
                        iconBackgroundColor: opt.color,
                        groupValue: selectedValue, 
                        onChanged: (Object? value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedValue = value as String;
                          });
                        }
                      )
                    }
                  ],

                  onConfirm: () {
                    onConfirm!(selectedValue);
                  },
                );
              }
            );
          }
        );
      }
    );
  }

  static Widget shimmerLoading(BuildContext context) {
    final Color loadingColor = SColors.getGreyscaleColor(context).withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Container(
            height: 41.0,
            width: 41.0,
            decoration: BoxDecoration(
              color: loadingColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),

          const SizedBox(width: 15.0),

          Container(
            height: 20.0,
            width: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: loadingColor
            ),
          ),

          const SizedBox(width: 20.0),

          Expanded(
            child: Container()
          ),

          Container(
            height: 15.0,
            width: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: loadingColor
            ),
          ),

          const SizedBox(width: 10.0),

          Container(
            height: 26.0,
            width: 26.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: loadingColor
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String shownValue = '';

    switch (value.runtimeType) {
      case String:
        shownValue = value as String;
        break;
      case bool:
        shownValue = (value as bool) ? 'Oui' : 'Non';
        break;
      case DropdownTileOption:
        shownValue = (value as DropdownTileOption).displayName;
        break;
      default:
        break;
    }

    return Material(
      color: transparentBackground ? Colors.transparent : SColors.getBackgroundColor(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
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
                padding: const EdgeInsets.all(7.5),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
    
              const SizedBox(width: 15.0),
    
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(
                    color: transparentBackground ? Colors.white : null
                  ),
              ),
    
              const SizedBox(width: 20.0),
    
              Expanded(
                child: Text(
                  shownValue,
                  style: TextStyle(
                    color: transparentBackground ? Colors.white : null
                  ),
                  textAlign: TextAlign.right,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                )
              ),
    
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 26.0,
                color: transparentBackground ? Colors.white : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownTileOption {
  final String name;
  final String displayName;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const DropdownTileOption({
    required this.name,
    required this.displayName,
    this.subtitle,
    required this.icon,
    required this.color
  });
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/models/user/privacysettings.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page_model.dart';
import 'package:schooly/widgets/tiles/dropdown_tile.dart';

class RegisterStepFive extends StatefulWidget {
  const RegisterStepFive({
    super.key,

    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterStepFive> createState() => _RegisterStepFiveState();
}

class _RegisterStepFiveState extends State<RegisterStepFive> {
  @override
  Widget build(BuildContext context) {
    return RegisterPageModel(
      registerModal: widget.registerModal,
      title: 'Paramètres de confidentialité',
      widgets: <Widget>[
        Column(
          children: <Widget>[
            DropdownTile.fromPrivacySetting(
              context: context, 
              privacySetting: widget.registerModal.privacySettings.profile,
              transparentBackground: true,
              onConfirm: (
                SPrivacySetting privacySetting,
                SPrivacyLevel? privacyLevel
              ) {
                setState(() {
                  widget.registerModal.privacySettings.profile = SPrivacy(
                    type: SPrivacyType.profile,
                    privacy: privacySetting
                  );
                });
              }
            ),

            DropdownTile.fromBool(
              context: context, 
              title: 'Demandes d\'ami', 
              description: 'Accepter les demandes d\'ami', 
              icon: Icons.person_add_alt_1_rounded, 
              color: const Color.fromRGBO(115, 214, 115, 1), 
              baseValue: widget.registerModal.privacySettings.acceptFriendRequests,
              onConfirm: (bool value) {
                setState(() {
                  widget.registerModal.privacySettings.acceptFriendRequests = value;
                });
              },
            ),

            DropdownTile.fromPrivacySetting(
              context: context, 
              privacySetting: widget.registerModal.privacySettings.grades,
              levels: <SPrivacyLevel>[
                SPrivacyLevel.gradeEverything,
                SPrivacyLevel.gradeAveragesOnly,
                SPrivacyLevel.gradeGlobalAverageOnly,
                SPrivacyLevel.gradeNothing,
              ],
              transparentBackground: true,
              onConfirm: (
                SPrivacySetting privacySetting,
                SPrivacyLevel? privacyLevel
              ) {
                setState(() {
                  widget.registerModal.privacySettings.grades = SPrivacy(
                    type: SPrivacyType.grades,
                    privacy: privacySetting,
                    level: privacyLevel
                  );
                });
              }
            ),

            DropdownTile.fromPrivacySetting(
              context: context, 
              privacySetting: widget.registerModal.privacySettings.location,
              levels: <SPrivacyLevel>[
                SPrivacyLevel.locationEverything,
                SPrivacyLevel.locationOnlyCity,
                SPrivacyLevel.locationOnlyCountry,
                SPrivacyLevel.locationNothing,
              ],
              transparentBackground: true,
              onConfirm: (
                SPrivacySetting privacySetting,
                SPrivacyLevel? privacyLevel
              ) {
                setState(() {
                  widget.registerModal.privacySettings.location = SPrivacy(
                    type: SPrivacyType.location,
                    privacy: privacySetting,
                    level: privacyLevel
                  );
                });
              }
            ),

            DropdownTile.fromPrivacySetting(
              context: context, 
              privacySetting: widget.registerModal.privacySettings.friendList,
              transparentBackground: true,
              onConfirm: (
                SPrivacySetting privacySetting,
                SPrivacyLevel? privacyLevel
              ) {
                setState(() {
                  widget.registerModal.privacySettings.friendList = SPrivacy(
                    type: SPrivacyType.friendList,
                    privacy: privacySetting,
                    level: privacyLevel
                  );
                });
              }
            )
          ]
        )
      ],
      onConfirm: () {
        widget.registerModal.setCurrentPage = widget.registerModal.currentPage + 1;

        context.push(
          '/register', 
          extra: widget.registerModal
        );
      },
    );
  }
}
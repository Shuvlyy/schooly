// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/user/privacysettings.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/dropdown_tile.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: SAppBar(
        leading: AppBarLeadingButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () {
            context.pop();
          }
        ),
        title: const SLogo()
      ),
      body: DefaultPageLayout(
        autoSpacing: false,
        body: <Widget>[
          Text(
            'Paramètres > Confidentialité',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          DropdownTile.fromPrivacySetting(
            context: context, 
            privacySetting: user.userData.settings.privacySettings!.profile,
            onConfirm: (
              SPrivacySetting privacySetting,
              SPrivacyLevel? privacyLevel
            ) async {
              SPrivacy oldValue = user.userData.settings.privacySettings!.profile;

              setState(() {
                user.userData.settings.privacySettings!.profile = SPrivacy(
                  type: SPrivacyType.profile,
                  privacy: privacySetting
                );
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

              if (result.failed) {
                setState(() {
                  user.userData.settings.privacySettings!.profile = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            }
          ),

          DropdownTile.fromBool(
            context: context, 
            title: 'Demandes d\'ami', 
            description: 'Accepter les demandes d\'ami', 
            icon: Icons.person_add_alt_1_rounded, 
            color: const Color.fromRGBO(115, 214, 115, 1), 
            baseValue: user.userData.settings.privacySettings!.acceptFriendRequests,
            onConfirm: (bool value) async {
              bool oldValue = user.userData.settings.privacySettings!.acceptFriendRequests;
              
              if (oldValue == value) return;

              setState(() {
                user.userData.settings.privacySettings!.acceptFriendRequests = value;
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

              if (result.failed) {
                setState(() {
                  user.userData.settings.privacySettings!.acceptFriendRequests = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            },
          ),

          DropdownTile.fromPrivacySetting(
            context: context, 
            privacySetting: user.userData.settings.privacySettings!.grades,
            levels: <SPrivacyLevel>[
              SPrivacyLevel.gradeEverything,
              SPrivacyLevel.gradeAveragesOnly,
              SPrivacyLevel.gradeGlobalAverageOnly,
              SPrivacyLevel.gradeNothing,
            ],
            onConfirm: (
              SPrivacySetting privacySetting,
              SPrivacyLevel? privacyLevel
            ) async {
              SPrivacy oldValue = user.userData.settings.privacySettings!.grades;

              setState(() {
                user.userData.settings.privacySettings!.grades = SPrivacy(
                  type: SPrivacyType.grades,
                  privacy: privacySetting,
                  level: privacyLevel
                );
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

              if (result.failed) {
                setState(() {
                  user.userData.settings.privacySettings!.grades = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            }
          ),

          DropdownTile.fromPrivacySetting(
            context: context, 
            privacySetting: user.userData.settings.privacySettings!.location,
            levels: <SPrivacyLevel>[
              SPrivacyLevel.locationEverything,
              SPrivacyLevel.locationOnlyCity,
              SPrivacyLevel.locationOnlyCountry,
              SPrivacyLevel.locationNothing,
            ],
            onConfirm: (
              SPrivacySetting privacySetting,
              SPrivacyLevel? privacyLevel
            ) async {
              SPrivacy oldValue = user.userData.settings.privacySettings!.location;

              setState(() {
                user.userData.settings.privacySettings!.location = SPrivacy(
                  type: SPrivacyType.location,
                  privacy: privacySetting,
                  level: privacyLevel
                );
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

              if (result.failed) {
                setState(() {
                  user.userData.settings.privacySettings!.location = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });
                
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            }
          ),

          DropdownTile.fromPrivacySetting(
            context: context, 
            privacySetting: user.userData.settings.privacySettings!.friendList,
            onConfirm: (
              SPrivacySetting privacySetting,
              SPrivacyLevel? privacyLevel
            ) async {
              SPrivacy oldValue = user.userData.settings.privacySettings!.friendList;

              setState(() {
                user.userData.settings.privacySettings!.friendList = SPrivacy(
                  type: SPrivacyType.friendList,
                  privacy: privacySetting,
                  level: privacyLevel
                );
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

              if (result.failed) {
                setState(() {
                  user.userData.settings.privacySettings!.friendList = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            }
          )
        ]
      )
    );
  }
}
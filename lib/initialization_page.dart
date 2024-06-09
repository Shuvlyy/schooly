// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/database_consts.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/common/utils.dart';
import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/privacysettings.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/sbadge.dart';
import 'package:schooly/models/user/settings.dart';
import 'package:schooly/models/user/studentinfo.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/models/user/suserdata.dart';
import 'package:schooly/pages/authentification/login_page.dart';
import 'package:schooly/pages/main/main_page.dart';
import 'package:schooly/pages/outdated_app_page.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/dialog_button.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/slogo.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({ super.key });

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  SUser? user;

  Future<Map<String, dynamic>>? _databaseConsts;

  bool loadProviderUser = true;

  @override
  void initState() {
    _databaseConsts = DatabaseService(uid: '').constsFromDatabase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // AuthentificationService().signOut();
    
    if (loadProviderUser) {
      user = Provider.of<SUser?>(context);
    } else {
      user = GetIt.I<SUser>();
    }

    DatabaseConsts databaseConsts;

    return FutureBuilder(
      future: _databaseConsts,
      builder: (
        BuildContext context, 
        AsyncSnapshot<Map<String, dynamic>> snapshot
      ) {
        if (!snapshot.hasData) {
          return const LoadingScreen(step: 'Chargement des données depuis la base de données');
        }

        databaseConsts = DatabaseConsts.fromMap(snapshot.data as Map<String, dynamic>);
        GetIt.I.registerSingleton<DatabaseConsts>(databaseConsts);
        
        if (!databaseConsts.acceptedVersions.split(',').contains(AppProperties.version)) {
          return const OutdatedAppPage();
        }

        if (user == null || !AuthentificationService().isLoggedIn) {
          user = null;
          return const LoginPage();
        }

        if (user!.userData.profile.appVersion == '' && loadProviderUser) {
          DatabaseService.getUserSnapshotByUid(user!.uid)
          .then((dynamic userQuery) {
            if (userQuery is SStatus) {
              return showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return ErrorPopup(
                    error: userQuery,
                    onConfirm: () {
                      Utils.exitApp();
                    },
                  );
                },
              );
            }

            Map<String, dynamic> userAsMap = (userQuery as DocumentSnapshot<Object?>).data() as Map<String, dynamic>;

            setState(() {
              user!.userData.profile.appVersion = userAsMap['profile']['appVersion'];
            });
          });

          return const LoadingScreen(step: 'Vérification du profil');
        }

        if (
          ['0.1a', '0.2a', '0.21a', '0.22.0a', '0.23.0d', /* '0.3.0d' <-- This one is temporary !! */].contains(user!.userData.profile.appVersion)
          && loadProviderUser
        ) {
          Timer(
            const Duration(seconds: 1), 
            () {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (
                      BuildContext context,
                      Function(void Function()) setModalState
                    ) {
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
                                color: const Color.fromRGBO(247, 102, 94, 1),
                                borderRadius: BorderRadius.circular(12.5),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(247, 102, 94, 1),
                                    blurRadius: 4
                                  )
                                ]
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10.0),

                            Text(
                              'Attention',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              '''
Votre compte a été utilisé pour la dernière fois sur la version ${user!.userData.profile.appVersion} de Schooly.

Pour des raisons techniques, pour passer sur la version ${AppProperties.version} de Schooly, vous devez réinitialiser votre compte.
Vous garderez toutes vos informations relatives à votre profil (nom d'utilisateur, classe, pseudo, badges...).

Souhaitez-vous continuer ?''',
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        actions: <Widget>[
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <DialogButton>[
                              DialogButton(
                                style: DialogButtonStyle.secondary, 
                                text: 'Annuler', 
                                onTap: () {
                                  return Utils.exitApp();
                                }
                              ),
                              DialogButton(
                                style: DialogButtonStyle.primary, 
                                text: 'Continuer', 
                                onTap: () async {
                                  // setState(() {
                                    // loading = true; // TODO: do that lol
                                  // });

                                  dynamic userQuery = await DatabaseService.getUserSnapshotByUid(user!.uid);

                                  if (userQuery is SStatus) {
                                    return showDialog(
                                      context: context, 
                                      builder: (BuildContext context) {
                                        return ErrorPopup(
                                          error: userQuery,
                                          onConfirm: () {
                                            Utils.exitApp();
                                          },
                                        );
                                      },
                                    );
                                  }

                                  Map<String, dynamic> oldUserAsMap = (userQuery as DocumentSnapshot<Object?>).data() as Map<String, dynamic>;

                                  SUser newUser = SUser(
                                    uid: user!.uid,
                                    userData: SUserData(
                                      disciplines: [],
                                      settings: SSettings(
                                        privacySettings: PrivacySettings(
                                          profile: const SPrivacy(
                                            privacy: SPrivacySetting.public, 
                                            type: SPrivacyType.profile
                                          ),
                                          grades: const SPrivacy(
                                            privacy: SPrivacySetting.public, 
                                            level: SPrivacyLevel.gradeEverything,
                                            type: SPrivacyType.grades
                                          ),
                                          location: const SPrivacy(
                                            privacy: SPrivacySetting.public, 
                                            level: SPrivacyLevel.locationEverything,
                                            type: SPrivacyType.location
                                          ),
                                          friendList: const SPrivacy(
                                            privacy: SPrivacySetting.public, 
                                            type: SPrivacyType.friendList
                                          ),
                                          acceptFriendRequests: true
                                        )
                                      ),
                                      profile: SProfile(
                                        username: oldUserAsMap['profile']['username'],
                                        displayName: oldUserAsMap['profile']['nickname'],

                                        joinedAt: (oldUserAsMap['profile']['joinedTimestamp'] as Timestamp?)?.toDate(),

                                        appVersion: AppProperties.version,

                                        locationInformations: LocationInformations(),

                                        studentInformations: StudentInformations(
                                          establishment: 
                                            oldUserAsMap['profile']['etablishment'] == '--' ? '' : oldUserAsMap['profile']['etablishment'],
                                          gradeClass: 
                                            oldUserAsMap['profile']['grade'] == '--' ? '' : oldUserAsMap['profile']['grade'],
                                        ),

                                        badges: 
                                          (oldUserAsMap['profile']['tags'] as List<dynamic>).map(
                                            (dynamic b) {
                                              return SBadge.fromName(b as String);
                                            }
                                          ).toList()
                                      )
                                    )
                                  );

                                  SStatus result = await DatabaseService(uid: newUser.uid).saveUser(newUser);

                                  if (result.failed) {
                                    Fluttertoast.showToast(
                                      msg: "Erreur: ${result.message}",
                                      backgroundColor: Colors.black.withOpacity(.5),
                                      fontSize: 16.0,
                                      toastLength: Toast.LENGTH_LONG
                                    );

                                    return Utils.exitApp();
                                  } else {
                                    setState(() {
                                      loadProviderUser = false;
                                      user = newUser;
                                      GetIt.I.registerSingleton<SUser>(newUser);
                                    });

                                    context.pop();
                                  }
                                }
                              )
                            ],
                          ),
                        ],
                      );
                    }
                  );
                },
              );
            }
          );
          return const LoadingScreen(step: 'Profil trop ancien > Demande de réinitialisation');
        }

        if (user!.userData.profile.appVersion != AppProperties.version) {
          user!.userData.profile.appVersion = AppProperties.version;

          Future<SStatus> result = DatabaseService(uid: user!.uid).saveUser(user!);

          result.then(
            (SStatus status) {
              if (status.failed) {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: status);
                  }
                );
              }
            }
          );
        }

        loadProviderUser = false;

        GetIt.I.registerSingleton<SUser>(user!);

        return const MainPage();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    required this.step
  });

  final String step;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(),
              const SLogo(
                rotate: true,
                size: 84.0
              ),
              Text(
                step,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white
                )
              )
            ]
          )
        )
      )
    );
  }
}
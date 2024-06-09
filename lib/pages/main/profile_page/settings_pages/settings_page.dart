// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/tiles/clickable_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<List> tiles = <List>[
    [
      Icons.person_rounded,
      const Color.fromRGBO(189, 171, 218, 1),
      'Compte',
      'accountSettingsPage'
    ],
    [
      Icons.lock_rounded,
      const Color.fromRGBO(237, 152, 152, 1),
      'Sécurité',
      'securitySettingsPage'
    ],
    [
      Icons.security_rounded,
      const Color.fromRGBO(158, 189, 219, 1),
      'Confidentialité',
      'privacySettingsPage'
    ],
    [
      Icons.language_rounded,
      const Color.fromRGBO(176, 236, 129, 1),
      'Langue',
      'languageSettingsPage'
    ],
    [
      Icons.settings_rounded,
      const Color.fromRGBO(237, 190, 144, 1),
      'Application',
      'appSettingsPage'
    ],
    [
      Icons.info_rounded,
      const Color.fromRGBO(183, 98, 193, 1),
      'À propos',
      'aboutPage'
    ]
  ];

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // final SUser user = GetIt.I<SUser>();

    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: SAppBar(
        leading: AppBarLeadingButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () {
            context.pop();
          }
        ),
        title: SLogo(rotate: loading)
      ),
      body: DefaultPageLayout(
        autoSpacing: false,
        padding: 20,
        body: <Widget>[
          Text(
            'Paramètres',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          for (List tile in tiles) ... {
            ClickableTile(
              icon: tile[0],
              iconBackgroundColor: tile[1],
              title: tile[2],
              onTap: () {
                context.go("/settingsPage/${tile[3]}");
              },
            )
          }
        ],
        trailing: SButton(
          icon: Icons.logout,
          backgroundColor: Colors.red,
          title: 'Se déconnecter',
          onTap: () {
            showDialog(
              context: context, 
              builder: (BuildContext context) {
                return SConfirmationDialog(
                  icon: Icons.logout_rounded, 
                  iconBackgroundColor: Colors.red,
                  title: 'Déconnexion', 
                  content: 'Êtes-vous sûr de vouloir vous déconnecter ?', 
                  cancelButtonTitle: 'Non',
                  onConfirm: () async {
                    setState(() {
                      loading = true;
                    });

                    AuthentificationService auth = AuthentificationService();
                    SStatus signOutStatus = await auth.signOut();

                    setState(() {
                      loading = false;
                    });

                    if (signOutStatus.failed) {
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return ErrorPopup(error: signOutStatus);
                        }
                      );
                    } else {
                      context.go('/');
                    }
                  }
                );
              },
            );
          },
        )
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/clickable_tile.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  Widget build(BuildContext context) {
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
            'Paramètres > Sécurité',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          ClickableTile(
            icon: Icons.lock_rounded,
            iconBackgroundColor: const Color.fromRGBO(237, 152, 152, 1),
            title: 'Mot de passe',
            subtitle: "Dernière modification le ...",
            onTap: () {
              // TODO: Change user's password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cette fonction n\'est pas encore implémentée.\nPour changer votre mot de passe, contactez moi sur n\'importe quel réseau social (cherchez "Shuvly").')
                )
              );
            },
          ),
        ]
      )
    );
  }
}
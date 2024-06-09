import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
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
            'Paramètres > Langue',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          Text(
            'Soon...',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          )
        ]
      )
    );
  }
}
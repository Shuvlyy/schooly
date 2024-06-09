// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/database_consts.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/icons/social_networks_icons_icons.dart';
import 'package:schooly/models/user/privacysettings.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/widgets/buttons/appbar_action.dart';
import 'package:schooly/widgets/clickable_text.dart';
import 'package:schooly/layouts/register_page_layout.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/textfields/white_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ super.key });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthentificationService _authentificationService = AuthentificationService();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();

  @override
  void dispose() {
    emailFieldController.dispose();
    passwordFieldController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool showValidatorErrors = false;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: AppBar(
        actions: [
          AppbarActionButton(
            text: 'S\'inscrire',
            onTap: () {
              if (!GetIt.I<DatabaseConsts>().areRegistrationsAuthorized) {
                return ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les inscriptions ne sont pas ouvertes pour le moment.')
                  )
                );
              }

              PrivacySettings privacySettings = PrivacySettings(
                grades: const SPrivacy(
                  type: SPrivacyType.grades,
                  level: SPrivacyLevel.gradeEverything
                ),
                location: const SPrivacy(
                  type: SPrivacyType.location,
                  level: SPrivacyLevel.locationEverything
                )
              );

              RegisterModal registerModal = RegisterModal();
              registerModal.setPrivacySettings = privacySettings;

              context.go(
                '/register',
                extra: registerModal
              );
            }
          )
        ],
        toolbarHeight: kToolbarHeight,
      ),
      body: Center(
        child: RegisterPageLayout(
          alignment: MainAxisAlignment.center,
          autoSpacing: false,
          body: <Widget>[
            SLogo(
              rotate: isLoading,
              size: 84.0
            ),
            const SizedBox(height: 20.0),
            Text(
              AppProperties.title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600
              ),
            ),
      
            const SizedBox(height: 40.0),
      
            Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  SWhiteTextField(
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email', 
                    icon: Icons.email_rounded, 
                    controller: emailFieldController, 
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse email.';
                      }

                      if (!Regexes.email.hasMatch(value)) {
                        return 'Veuillez entrer une adresse email valide.';
                      }
                    },
                    showError: showValidatorErrors,
                  ),
    
                  const SizedBox(height: 15.0),
    
                  SWhiteTextField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    labelText: 'Mot de passe', 
                    icon: Icons.lock_rounded, 
                    controller: passwordFieldController, 
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe.';
                      }
                    },
                    showError: showValidatorErrors,
                  )
                ],
              ),
            ),
    
            const SizedBox(height: 10.0),
    
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <ClickableText>[
                ClickableText(
                  text: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline
                    )
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cette fonction n\'est pas encore implémentée.\nPour réinitialiser votre mot de passe, contactez moi sur n\'importe quel réseau social (cherchez "Shuvly").')
                      )
                    );
                  }
                )
              ]
            ),
    
            const SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <SButton>[
                SButton(
                  icon: Icons.arrow_forward_ios_rounded, 
                  onTap: () async {
                    setState(() => showValidatorErrors = true);
                    
                    if (_loginFormKey.currentState?.validate() ?? false) {
                      setState(() => isLoading = true);

                      dynamic loginResult = await _authentificationService
                        .signInWithEmailAndPassword(
                          emailFieldController.value.text, 
                          passwordFieldController.value.text
                        );
                      
                      setState(() => isLoading = false);

                      if (loginResult is SStatus?) {
                        showDialog(
                          context: context, 
                          builder: (BuildContext context) => ErrorPopup(error: loginResult as SStatus)
                        );
                      } else {
                        GetIt.I.registerSingleton<SUser>(loginResult as SUser);
                      }
                    } else {
                      context.go('/');
                    }
                  }
                ),
              ]
            ),
    
            const SizedBox(height: 20.0),
    
            Separator(
              width: MediaQuery.of(context).size.width - 110*2, // 120 represents the margin, *2 for both sides of the screen
              color: Colors.white,
              text: 'Ou continuer avec',
            ),
    
            const SizedBox(height: 20.0),
    
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SButton(
                  backgroundColor: Colors.green, 
                  icon: Icons.android, 
                  onTap: () {
                    // Google login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cette fonction n\'est pas encore implémentée.')
                      )
                    );
                  }
                ),
    
                const SizedBox(width: 20.0),
    
                SButton(
                  backgroundColor: Colors.black, 
                  icon: Icons.apple_rounded, 
                  onTap: () {
                    // Apple login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cette fonction n\'est pas encore implémentée.')
                      )
                    );
                  }
                ),
    
                const SizedBox(width: 20.0),
    
                SButton(
                  backgroundColor: const Color.fromRGBO(28, 150, 232, 1), 
                  icon: SocialNetworksIcons.twitter, 
                  onTap: () {
                    // Twitter login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cette fonction n\'est pas encore implémentée.')
                      )
                    );
                  }
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}
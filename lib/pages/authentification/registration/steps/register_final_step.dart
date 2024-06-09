import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/widgets/animated_ellipsis_text.dart';
import 'package:schooly/layouts/register_page_layout.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/error_popup.dart';

class RegisterFinalStep extends StatefulWidget {
  const RegisterFinalStep({
    super.key,

    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterFinalStep> createState() => _RegisterFinalStepState();
}

class _RegisterFinalStepState extends State<RegisterFinalStep> {
  final AuthentificationService _authentificationService = AuthentificationService();

  Future<dynamic>? _registerCallbackResult;

  @override
  void initState() {
    _registerCallbackResult = _authentificationService.registerWithEmailAndPassword(widget.registerModal);
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic registerCallbackResult;

    return FutureBuilder(
      future: _registerCallbackResult,
      builder: (
        BuildContext context, 
        AsyncSnapshot<dynamic> snapshot
      ) {
        if (!snapshot.hasData) {
          return WillPopScope(
            onWillPop: () async {
              // registerModal.setCurrentPage(registerModal.currentPage - 1);
              return false;
            },
            child: GradientScaffold(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.fromRGBO(225, 144, 235, 1),
                  Color.fromRGBO(109, 31, 118, 1)
                ]
              ),
              body: Center(
                child: RegisterPageLayout(
                  alignment: MainAxisAlignment.center,
                  autoSpacing: true,
                  spacing: 20.0,
                  body: <Widget>[
                    const SLogo(
                      rotate: true,
                      size: 84.0,
                    ),
                    AnimatedEllipsisText(
                      'Création du compte',
                      style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      textAlign: TextAlign.center,
                    )
                  ]
                )
              )
            )
          );
        }

        registerCallbackResult = _registerCallbackResult;

        if (registerCallbackResult is SStatus) {
          showDialog(
            context: context, 
            builder: (BuildContext context) => ErrorPopup(error: registerCallbackResult)
          );
        }

        context.go('/');

        return const Text('YKWIM?');
      },
    );
  }
}
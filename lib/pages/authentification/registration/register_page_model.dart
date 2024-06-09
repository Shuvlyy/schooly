import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/layouts/register_page_layout.dart';
import 'package:schooly/widgets/dot_stepper.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';
import 'package:schooly/widgets/sappbar.dart';

class RegisterPageModel extends StatelessWidget {
  const RegisterPageModel({
    super.key,

    required this.registerModal,
    required this.title,
    required this.widgets,
    required this.onConfirm
  });

  final RegisterModal registerModal;
  final String title;
  final List<Widget> widgets;
  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (registerModal.currentPage == 0) {
          context.go('/');
        } else {
          registerModal.setCurrentPage = registerModal.currentPage - 1;
        }
        
        return false;
      },
      child: GradientScaffold(
        gradient: SColors.getScaffoldGradient(context),
        appBar: SAppBar(
          leading: AppBarLeadingButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () {
              if (registerModal.currentPage == 0) {
                return context.go('/');
              }
              
              registerModal.setCurrentPage = registerModal.currentPage - 1;
              context.pop();
            },
          ),
          title: const SLogo(),
        ),
        body: Center(
          child: RegisterPageLayout(
            alignment: MainAxisAlignment.center,
            autoSpacing: true,
            spacing: 40.0,
            body: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500
                ),
              ),
    
              for (Widget widget in widgets) ... {
                widget
              },

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SButton(
                    icon: Icons.arrow_forward_ios_rounded, 
                    onTap: onConfirm,
                  )
                ]
              ),
            
              DotStepper(
                amount: registerModal.totalPages,
                currentPage: registerModal.currentPage + 1,
              )
            ]
          )
        )
      ),
    );
  }
}
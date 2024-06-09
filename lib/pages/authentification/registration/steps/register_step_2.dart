import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page_model.dart';
import 'package:schooly/widgets/textfields/white_text_field.dart';

class RegisterStepTwo extends StatefulWidget {
  const RegisterStepTwo({
    super.key,
    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterStepTwo> createState() => _RegisterStepTwoState();
}

class _RegisterStepTwoState extends State<RegisterStepTwo> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final emailFieldController = TextEditingController();
    
  bool showValidatorErrors = false;

  @override
  void initState() {
    emailFieldController.text = widget.registerModal.email;

    super.initState();
  }

  @override
  void dispose() {
    emailFieldController.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return RegisterPageModel(
      registerModal: widget.registerModal,
      title: 'Entrez votre adresse email',
      widgets: <Widget>[
        Form(
          key: formKey,
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
              )
            ],
          ),
        ),
      ],
      onConfirm: () {
        setState(() => showValidatorErrors = true);

        if (formKey.currentState!.validate()) {
          widget.registerModal.setCurrentPage = widget.registerModal.currentPage + 1;
          widget.registerModal.setEmail = emailFieldController.value.text;

          context.push(
            '/register', 
            extra: widget.registerModal
          );
        }
      },
    );
  }
}
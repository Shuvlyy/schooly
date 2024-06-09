// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page_model.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/textfields/white_text_field.dart';

class RegisterStepOne extends StatefulWidget {
  const RegisterStepOne({
    super.key,
    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterStepOne> createState() => _RegisterStepOneState();
}

class _RegisterStepOneState extends State<RegisterStepOne> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController displayNameFieldController = TextEditingController();
  final TextEditingController usernameFieldController = TextEditingController();
    
  bool showValidatorErrors = false;

  bool usernameVerificationLoading = false;
  bool? isUsernameTaken;

  @override
  void initState() {
    displayNameFieldController.text = widget.registerModal.displayName;
    usernameFieldController.text = widget.registerModal.username;

    super.initState();
  }

  @override
  void dispose() {
    displayNameFieldController.dispose();
    usernameFieldController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPageModel(
      registerModal: widget.registerModal,
      title: 'Comment doit-on vous appeler ?',
      widgets: <Widget>[
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SWhiteTextField(
                keyboardType: TextInputType.name,
                labelText: 'Pseudo', 
                icon: Icons.person_rounded, 
                controller: displayNameFieldController, 
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un pseudo.';
                  }

                  if (value.length > AppProperties.maxDisplayNameLength) {
                    return "Votre pseudo ne peut contenir que ${AppProperties.maxDisplayNameLength} caractères maximum.";
                  }
                },
                showError: showValidatorErrors,
              ),
  
              const SizedBox(height: 15.0),
  
              SWhiteTextField(
                keyboardType: TextInputType.name,
                labelText: "Nom d'utilisateur", 
                icon: Icons.alternate_email_rounded, 
                trailing: 
                  isUsernameTaken == null 
                  ? null
                  : (
                    usernameVerificationLoading
                    ? const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(),
                    )
                    : (
                      isUsernameTaken!
                      ? const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                      )
                      : const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                      )
                    )
                  ),
                controller: usernameFieldController, 
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un nom d'utilisateur.";
                  }

                  if (value.length > AppProperties.maxUsernameLength) {
                    return "Votre nom d'utilisateur ne peut contenir que ${AppProperties.maxUsernameLength} caractères maximum.";
                  }

                  if (!Regexes.username.hasMatch(value)) {
                    return "Veuillez entrer un nom d'utilisateur valide.\n(voir conditions en dessous)";
                  }
                },
                showError: showValidatorErrors,
              ),
      
              const SizedBox(height: 5.0),
      
              const Text(
                'Uniquement les minuscules, les chiffres et les underscores sont autorisés',
                style: TextStyle(
                  color: Colors.white
                ),
              )
            ],
          ),
        ),
      ],
      onConfirm: () async {
        if (!showValidatorErrors) {
          setState(() => showValidatorErrors = true);
        }

        setState(() { 
          usernameVerificationLoading = true; 
        });

        bool doesUsernameExists = await DatabaseService.doesUsernameExists(usernameFieldController.text);

        setState(() {
          isUsernameTaken = doesUsernameExists;
          usernameVerificationLoading = false;
        });

        if (doesUsernameExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ce nom d\'utilisateur est déjà pris.')
            )
          );
          return;
        }

        if (formKey.currentState!.validate()) {
          widget.registerModal.setCurrentPage = widget.registerModal.currentPage + 1;
          widget.registerModal.setDisplayName = displayNameFieldController.value.text;
          widget.registerModal.setUsername = usernameFieldController.value.text;
          
          context.push(
            '/register', 
            extra: widget.registerModal
          );
        }
      },
    );
  }
}
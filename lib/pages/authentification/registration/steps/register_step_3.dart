import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page_model.dart';
import 'package:schooly/widgets/input_validation.dart';
import 'package:schooly/widgets/textfields/white_text_field.dart';

class RegisterStepThree extends StatefulWidget {
  const RegisterStepThree({
    super.key,
    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterStepThree> createState() => _RegisterStepThreeState();
}

class _RegisterStepThreeState extends State<RegisterStepThree> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final passwordFieldController = TextEditingController();
  final passwordConfirmationFieldController = TextEditingController();
  
  bool showPasswordFieldValue = false;
  bool showPasswordConfirmationFieldValue = false;

  bool showValidatorErrors = false;

  @override
  void initState() {
    passwordFieldController.text = widget.registerModal.password;
    passwordConfirmationFieldController.text = widget.registerModal.password;

    super.initState();
  }

  @override
  void dispose() {
    passwordFieldController.dispose();
    passwordConfirmationFieldController.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return RegisterPageModel(
      registerModal: widget.registerModal,
      widgets: <Widget>[
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SWhiteTextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: !showPasswordFieldValue,
                labelText: 'Mot de passe', 
                icon: Icons.lock_rounded, 
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      showPasswordFieldValue = !showPasswordFieldValue;
                    });
                  }, 
                  icon: Icon(
                    showPasswordFieldValue ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                    color: Colors.white,
                  )
                ),
                controller: passwordFieldController, 
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe.';
                  }

                  if (!Regexes.password.hasMatch(value)) {
                    return 'Veuillez respecter les conditions ci-dessous.';
                  }
                },
                onChanged: (_) {
                  setState(() {});
                },
                showError: showValidatorErrors,
              ),
  
              const SizedBox(height: 15.0),
  
              SWhiteTextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: !showPasswordConfirmationFieldValue,
                labelText: "Confirmation du mot de passe", 
                icon: Icons.lock_rounded, 
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      showPasswordConfirmationFieldValue = !showPasswordConfirmationFieldValue;
                    });
                  }, 
                  icon: Icon(
                    showPasswordConfirmationFieldValue ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                    color: Colors.white,
                  )
                ),
                controller: passwordConfirmationFieldController, 
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez confirmer votre mot de passe.";
                  }
      
                  if (passwordFieldController.value.text != value) {
                    return "Les deux mots de passe ne correspondent pas.";
                  }
                },
                showError: showValidatorErrors,
              ),
      
              const SizedBox(height: 15.0),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Wrap>[
                  Wrap(
                    spacing: 7.0,
                    runSpacing: 7.0,
                    children: <InputValidationIndicator>[
                      InputValidationIndicator(
                        rule: '8 caractères minimum', 
                        regex: Regexes.eightCharactersMinimum, 
                        strToTest: passwordFieldController.value.text
                      ),
                
                      InputValidationIndicator(
                        rule: 'Majuscule(s)', 
                        regex: Regexes.oneCapitalizedLetter, 
                        strToTest: passwordFieldController.value.text
                      ),
                
                      InputValidationIndicator(
                        rule: 'Minuscule(s)', 
                        regex: Regexes.oneNonCapitalizedLetter, 
                        strToTest: passwordFieldController.value.text
                      ),
                
                      InputValidationIndicator(
                        rule: 'Caractères spéciaux', 
                        regex: Regexes.oneSpecialCharacter, 
                        strToTest: passwordFieldController.value.text
                      )
                    ],
                  ),
                ]
              )
      
              // const Text(
              //   'Uniquement les minuscules, les chiffres et les underscores sont autorisés',
              //   style: TextStyle(
              //     color: Colors.white
              //   ),
              // )
            ],
          ),
        ),
      ],
      title: 'Créez un mot de passe sécurisé',
      onConfirm: () {
        setState(() => showValidatorErrors = true);

        if (formKey.currentState!.validate()) {
          widget.registerModal.setCurrentPage = widget.registerModal.currentPage + 1;
          widget.registerModal.setPassword = passwordFieldController.value.text;

          context.push(
            '/register', 
            extra: widget.registerModal
          );
        }
      },
    );
  }
}
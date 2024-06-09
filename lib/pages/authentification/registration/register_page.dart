import 'package:flutter/material.dart';
import 'package:schooly/pages/authentification/registration/steps/register_final_step.dart';
import 'package:schooly/pages/authentification/registration/steps/register_step_5.dart';

import 'register_modal.dart';
import 'steps/register_step_1.dart';
import 'steps/register_step_2.dart';
import 'steps/register_step_3.dart';
import 'steps/register_step_4.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({
    super.key,
    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  Widget build(BuildContext context) {
    switch (registerModal.currentPage) {
      case 0:
        return RegisterStepOne(registerModal: registerModal);
      case 1:
        return RegisterStepTwo(registerModal: registerModal);
      case 2:
        return RegisterStepThree(registerModal: registerModal);
      case 3:
        return RegisterStepFour(registerModal: registerModal);
      case 4:
        return RegisterStepFive(registerModal: registerModal);
      case 5:
        return RegisterFinalStep(registerModal: registerModal);
      default:
        return RegisterStepOne(registerModal: registerModal);
    }
  }
}

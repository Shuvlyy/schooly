import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page_model.dart';
import 'package:schooly/widgets/selectable_button.dart';

class RegisterStepFour extends StatefulWidget {
  const RegisterStepFour({
    super.key,

    required this.registerModal
  });

  final RegisterModal registerModal;

  @override
  State<RegisterStepFour> createState() => _RegisterStepFourState();
}

class _RegisterStepFourState extends State<RegisterStepFour> {
  Periodicity selectedPeriodicity = Periodicity.semester;

  @override
  void initState() {
    selectedPeriodicity = widget.registerModal.periodicity;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPageModel(
      registerModal: widget.registerModal,
      title: 'Quelle périodicité préférez-vous ?',
      widgets: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableButton(
                title: Periodicity.semester.displayPeriodicityName,
                subtitle: Periodicity.semester.description, 
                value: Periodicity.semester, 
                groupValue: selectedPeriodicity, 
                crossAxisAlignment: CrossAxisAlignment.end, 
                onTap: (Object value) {
                  setState(() => selectedPeriodicity = value as Periodicity);
                }
              ),

              const SizedBox(width: 10.0),

              SelectableButton(
                title: Periodicity.trimester.displayPeriodicityName,
                subtitle: Periodicity.trimester.description, 
                value: Periodicity.trimester,
                groupValue: selectedPeriodicity, 
                onTap: (Object value) {
                  setState(() => selectedPeriodicity = value as Periodicity);
                }
              ),
            ],
          ),
        )
      ],
      onConfirm: () {
        widget.registerModal.setCurrentPage = widget.registerModal.currentPage + 1;
        widget.registerModal.setPeriodicity = selectedPeriodicity;

        context.push(
          '/register', 
          extra: widget.registerModal
        );
      },
    );
  }
}
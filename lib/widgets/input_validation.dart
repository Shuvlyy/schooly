import 'package:flutter/material.dart';

class InputValidationIndicator extends StatelessWidget {
  const InputValidationIndicator({
    super.key,
    required this.rule,
    required this.regex,
    required this.strToTest
  });

  final String rule;
  final RegExp regex;
  final String strToTest;

  @override
  Widget build(BuildContext context) {
    bool isRuleRespected = regex.hasMatch(strToTest);

    return Container(
      decoration: BoxDecoration(
        color: 
          isRuleRespected
          ? Colors.lightGreen.withOpacity(0.4)
          : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.0)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isRuleRespected) ... {
            const Icon(
              Icons.check_rounded,
              color: Colors.lightGreen,
              size: 20.0,
            ),
            const SizedBox(width: 5.0)
          },

          Text(
            rule,
            style: const TextStyle(
              color: Colors.white
            ),
          )
        ],
      ),
    );
  }
}
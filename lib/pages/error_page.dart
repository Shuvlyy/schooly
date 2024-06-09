import 'package:flutter/material.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({ super.key });

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.fromRGBO(255, 102, 99, 1),
          Color.fromRGBO(194, 58, 34, 1),
        ]
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'On dirait bien que vous vous êtes perdu(e)'
            ),

            // SButton(
            //   text: "Revenir à l'accueil",
            //   onTap: () {
            //     context.go('/');
            //   }
            // )
          ]
        )
      )
    );
  }
}
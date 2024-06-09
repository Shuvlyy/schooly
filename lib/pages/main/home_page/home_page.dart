import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/widgets/evolution.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/percent_indicators/scircular_percent_indicator.dart';
import 'package:schooly/widgets/sappbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({ super.key });

  @override
  Widget build(BuildContext context) {
    final Stream<SUser> userStream = GetIt.I<Stream<SUser>>();

    return StreamBuilder(
      stream: userStream,
      builder: (
        BuildContext context, 
        AsyncSnapshot<SUser> snapshot
      ) {
        SUser user = GetIt.I<SUser>();

        if (snapshot.hasData) {
          GetIt.I.registerSingleton<SUser>(snapshot.data!);
        }

        final int gradesAmount = user.userData.getGradesAmount();

        return GradientScaffold(
          gradient: SColors.getScaffoldGradient(context),
          appBar: const SAppBar(
            title: SLogo()
          ),
          body: DefaultPageLayout(
            body: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.go('/averageGrade');
                  },
                  borderRadius: BorderRadius.circular(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SCircularPercentIndicator.fromGrade(
                            Grade(grade: user.userData.getAverageGrade()),
                            context
                          ),
                          const SizedBox(width: 15.0),
                          SizedBox(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Text>[
                                    Text(
                                      'Moyenne générale',
                                      style: Theme.of(context).textTheme.bodyLarge
                                    ),
                                    Text(
                                      "${user.userData.settings.periodicity.displayName} ${user.userData.settings.periodIndex + 1}",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: SColors.getGreyscaleColor(context),
                                      )
                                    )
                                  ],
                                ),
                                Evolution(
                                  a: gradesAmount >= 2 ? user.userData.getAverageGradeEvolution().elementAt(gradesAmount - 2) : -1,
                                  b: user.userData.getAverageGrade(), 
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        );
      },
    );
  }
}
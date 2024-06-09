// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_action.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/evolution.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/percent_indicators/scircular_percent_indicator.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/select_indicator.dart';

class EditDisciplinePage extends StatefulWidget {
  final int disciplineIndex;
  
  const EditDisciplinePage({
    super.key,

    required this.disciplineIndex
  });

  @override
  State<EditDisciplinePage> createState() => _EditDisciplinePageState();
}

class _EditDisciplinePageState extends State<EditDisciplinePage> {
  List<Grade> gradesInProgress = [];
  List<bool> selectedGrades = [];

  bool firstLoading = true;

  bool loading = false;
  
  @override
  Widget build(BuildContext context) {
    Stream<SUser> userStream = GetIt.I<Stream<SUser>>();

    return StreamBuilder(
      stream: userStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<SUser> snapshot
      ) {
        SUser user = GetIt.I<SUser>();

        if (snapshot.hasData) {
          user = snapshot.data!;
          GetIt.I.registerSingleton<SUser>(user);
        }

        final Discipline discipline = user.userData.disciplines.elementAt(widget.disciplineIndex);
        final int periodIndex = user.userData.settings.periodIndex;
        final Period currentPeriod = discipline.periods.elementAt(periodIndex);
        final int gradesAmount = currentPeriod.grades.length;
        
        if (firstLoading) {
          firstLoading = false;

          gradesInProgress = List.from(currentPeriod.grades);
          selectedGrades = List.generate(gradesInProgress.length, (_) => false);
        }

        return GradientScaffold(
          gradient: SColors.getScaffoldGradient(context),
          appBar: SAppBar(
            leading: AppBarLeadingButton(
              icon: Icons.close_rounded,
              onTap: () {
                context.pop();
              },
            ),
            title: SLogo(rotate: loading),
            actions: <AppbarActionButton>[
              AppbarActionButton(
                icon: Icons.done_rounded,
                onTap: () async {
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return SConfirmationDialog(
                        icon: Icons.done_rounded, 
                        iconBackgroundColor: Theme.of(context).primaryColor,
                        title: 'Confirmation', 
                        content: 'Confirmez-vous ?', 
                        cancelButtonTitle: 'Non',
                        onConfirm: () async {
                          context.pop();

                          setState(() {
                            loading = true;
                          });

                          List<Grade> oldGrades = List<Grade>.from(currentPeriod.grades); // in case the request fails
                          
                          user.userData.disciplines.elementAt(widget.disciplineIndex).periods.elementAt(periodIndex).grades = gradesInProgress;
                          
                          GetIt.I.registerSingleton<SUser>(user);

                          final SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

                          setState(() {
                            loading = false;
                          });

                          if (result.failed) {
                            user.userData.disciplines.elementAt(widget.disciplineIndex).periods.elementAt(periodIndex).grades = oldGrades;

                            GetIt.I.registerSingleton<SUser>(user);
                            
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) {
                                return ErrorPopup(error: result);
                              },
                            );
                          }
                        }
                      );
                    }
                  );
                },
              )
            ],
          ),
          body: DefaultPageLayout(
            leading: Column(
              children: <Widget>[
                Text(
                  discipline.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                ),
                if (currentPeriod.grades.isNotEmpty) ... {
                  Text(
                    "$gradesAmount note${gradesAmount == 1 ? '' : 's'}",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade300
                    ),
                  )
                },
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[    
                    Column(
                      children: <Widget>[
                        SCircularPercentIndicator.fromGrade(
                          Grade(grade: discipline.getAverageGrade(user.userData.settings.periodIndex)),
                          context,
                          type: SCircularPercentIndicatorType.big
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Evolution(
                  a: discipline.getAverageGradeAtTMinus(user.userData.settings.periodIndex, 1),
                  b: discipline.getAverageGrade(user.userData.settings.periodIndex), 
                  showBackground: true,
                ),
                const SizedBox(height: 15.0),
                Text(
                  "${user.userData.settings.periodicity.displayName} ${user.userData.settings.periodIndex + 1}",
                  style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(
                      color: Colors.white
                    )
                )
              ],
            ),
            body: <Widget>[
              SizedBox(
                height: (gradesInProgress.length * 60),
                child: ReorderableListView.builder(
                  itemBuilder: (
                    BuildContext context, 
                    int index
                  ) {
                    Grade grade = gradesInProgress.elementAt(index);

                    return Material(
                      key: Key('$index'),
                      borderRadius: BorderRadius.circular(5.0),
                      color: SColors.getBackgroundColor(context),
                      child: InkWell(
                        onTap: () {
                          // select or deselect
                          setState(() {
                            selectedGrades[index] = !selectedGrades[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(5.0),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SelectIndicator(active: selectedGrades.elementAt(index)),
                              const SizedBox(width: 10.0),
                              IntrinsicWidth(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Text>[
                                          Text(
                                            "${grade.type.displayName} du ${DateFormat('dd/MM/yyyy').format(grade.creationDate!)}",
                                            style: Theme.of(context).textTheme.bodyLarge
                                          ),
                                          Text(
                                            grade.display,
                                            style: Theme.of(context).textTheme.bodyLarge
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    LinearPercentIndicator(
                                      padding: const EdgeInsets.all(0.0),
                                      lineHeight: 3.0,
                                      width: MediaQuery.of(context).size.width - 110,
                                      animation: true,
                                      animationDuration: 300,
                                      percent: grade.toPercentage,
                                      backgroundColor: Colors.grey.shade300,
                                      progressColor: grade.color,
                                      barRadius: const Radius.circular(1.5),
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.drag_indicator_rounded)
                            ],
                          ),
                        ),
                      )
                    );
                  }, 
                  itemCount: gradesInProgress.length, 
                  onReorder: (
                    int oldIndex, 
                    int newIndex
                  ) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    final Grade grade = gradesInProgress.removeAt(oldIndex);
                    final bool gradeSelectState = selectedGrades.removeAt(oldIndex);
                    gradesInProgress.insert(newIndex, grade);
                    selectedGrades.insert(newIndex, gradeSelectState);
                  },
                ),
              )
            ]
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // confirmation dialog ?

              for (int k = 0; k < gradesInProgress.length; k++) {
                if (selectedGrades.elementAt(k)) {
                  setState(() {
                    gradesInProgress.removeAt(k);
                    selectedGrades.removeAt(k);
                  });
                }
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            backgroundColor: Colors.red,
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      }
    );
  }
}
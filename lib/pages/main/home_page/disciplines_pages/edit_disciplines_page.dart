// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
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

class EditDisciplinesPage extends StatefulWidget {
  const EditDisciplinesPage({super.key});

  @override
  State<EditDisciplinesPage> createState() => _EditDisciplinesPageState();
}

class _EditDisciplinesPageState extends State<EditDisciplinesPage> {
  List<Discipline> disciplinesInProgress = [];
  List<bool> selectedDisciplines = [];

  final ScrollController scrollController = ScrollController();

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

        if (firstLoading) {
          disciplinesInProgress = List.from(user.userData.disciplines);
          selectedDisciplines = List.generate(disciplinesInProgress.length, (_) => false);

          firstLoading = false;
        }

        final int periodIndex = user.userData.settings.periodIndex;

        final int gradesAmount = user.userData.getGradesAmount(periodIndex: periodIndex);

        return GradientScaffold(
          gradient: SColors.getScaffoldGradient(context),
          appBar: SAppBar(
            leading: AppBarLeadingButton(
              icon: Icons.close_rounded,
              onTap: () {
                context.pop();
              },
            ),
            title: SLogo(
              rotate: loading,
            ),
            actions: <AppbarActionButton>[
              AppbarActionButton(
                icon: Icons.done_rounded,
                onTap: () {
                  // confirm
                  
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

                          List<Discipline> oldDisciplines = List<Discipline>.from(user.userData.disciplines); // in case the request fails
                          
                          user.userData.disciplines = disciplinesInProgress;
                          
                          GetIt.I.registerSingleton<SUser>(user);

                          final SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

                          setState(() {
                            loading = false;
                          });

                          if (result.failed) {
                            user.userData.disciplines = oldDisciplines;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SCircularPercentIndicator.fromGrade(
                          Grade(grade: user.userData.getAverageGrade()),
                          context,
                          type: SCircularPercentIndicatorType.big
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Evolution(
                  a: gradesAmount >= 2 ? user.userData.getAverageGradeEvolution(periodIndex: periodIndex).elementAt(gradesAmount - 2) : -1,
                  b: user.userData.getAverageGrade(periodIndex: periodIndex), 
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
                height: disciplinesInProgress.length * 60,
                child: ReorderableListView.builder(
                  itemBuilder: (
                    BuildContext context, 
                    int index
                  ) {
                    Discipline discipline = disciplinesInProgress.elementAt(index);
              
                    final double disciplineAverageGrade = 
                      discipline.getAverageGrade(periodIndex);
              
                    final double disciplinePercentIndicatorAverageGrade = 
                      discipline.getPercentIndicatorAverageGrade(periodIndex);
                    
                    final String disciplineDisplayAverageGrade =
                      discipline.getDisplayAverageGrade(periodIndex);
                            
                    return Material(
                      key: Key('$index'),
                      borderRadius: BorderRadius.circular(5.0),
                      color: SColors.getBackgroundColor(context),
                      child: InkWell(
                        onTap: () {
                          // select or deselect
                          setState(() {
                            selectedDisciplines[index] = !selectedDisciplines[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(5.0),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SelectIndicator(active: selectedDisciplines.elementAt(index)),
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
                                            discipline.name,
                                            style: Theme.of(context).textTheme.bodyLarge
                                          ),
                                          Text(
                                            disciplineDisplayAverageGrade,
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
                                      percent: disciplinePercentIndicatorAverageGrade,
                                      backgroundColor: Colors.grey.shade300,
                                      progressColor: Grade(grade: disciplineAverageGrade).color,
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
                  itemCount: disciplinesInProgress.length, 
                  scrollController: scrollController,
                  onReorder: (
                    int oldIndex, 
                    int newIndex
                  ) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    final Discipline discipline = disciplinesInProgress.removeAt(oldIndex);
                    disciplinesInProgress.insert(newIndex, discipline);
                  },
                ),
              )
            ]
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return SConfirmationDialog(
                    icon: Icons.done_rounded, 
                    iconBackgroundColor: Theme.of(context).primaryColor,
                    title: 'Confirmation', 
                    content: 'Confirmez-vous la suppression de ces matières ?', // TODO: Change this weird message (precise that deleted disciplines will be permanently deleted when the user confirms the overall modification) 
                    cancelButtonTitle: 'Non',
                    onConfirm: () async {
                      context.pop();

                      for (int k = 0; k < disciplinesInProgress.length; k++) {
                        if (selectedDisciplines.elementAt(k)) {
                          setState(() {
                            disciplinesInProgress.removeAt(k);
                            selectedDisciplines.removeAt(k);
                          });
                        }
                      }
                    }
                  );
                }
              );
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
        );
      }
    );
  }
}
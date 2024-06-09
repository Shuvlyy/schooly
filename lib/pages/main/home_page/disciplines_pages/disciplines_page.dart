// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/buttons/appbar_popup_menu_button.dart';
import 'package:schooly/widgets/error_text.dart';
import 'package:schooly/widgets/evolution.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/percent_indicators/scircular_percent_indicator.dart';
import 'package:schooly/widgets/popup_menu_single_item.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/popups/modal_bottom_sheet_layout.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/textfields/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'disciplines_stats_page.dart';

class AverageGradePage extends StatefulWidget {
  const AverageGradePage({ super.key });

  @override
  State<AverageGradePage> createState() => _AverageGradePageState();
}

class _AverageGradePageState extends State<AverageGradePage> {
  final List<Widget> _pages = <Widget>[
    const DisciplinesPage(),
    const DisciplinesStatsPage()
  ];

  int _selectedDestination = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: SAppBar(
        leading: AppBarLeadingButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () {
            context.pop();
          }
        ),
        title: const SLogo(),
        actions: <PopupMenuButton>[
          if (_selectedDestination == 0) ... {
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
              ),
              child: const AppbarPopupMenuButton(),
              itemBuilder: (BuildContext context) =>
                <PopupMenuItem<String>>[
                  const PopupMenuItem(
                    value: 'reorder',
                    child: PopupMenuSingleItem(
                      text: 'Trier',
                      icon: Icons.list_rounded,
                    )
                  )
                ],
              onSelected: (String? value) {
                switch (value) {
                  case 'reorder':
                    if (user.userData.disciplines.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez avoir ajouté au moins une matière.')
                        )
                      );
                      break;
                    }

                    context.go('/averageGrade/editDisciplinesPage');
                    break;
                  default:
                    break;
                }
              },
            )
          }
        ],
      ),
      body: _pages.elementAt(_selectedDestination),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.list_rounded), 
            label: 'Matières'
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded), 
            label: 'Statistiques'
          )
        ],
      ),
    );
  }
}

class DisciplinesPage extends StatefulWidget {
  const DisciplinesPage({ super.key });

  @override
  State<DisciplinesPage> createState() => _DisciplinesPageState();
}

class _DisciplinesPageState extends State<DisciplinesPage> {
  final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();
  int periodIndex = GetIt.I<SUser>().userData.settings.periodIndex;

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

        final int gradesAmount = user.userData.getGradesAmount(periodIndex: periodIndex);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: DefaultPageLayout(
            leading: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: 
                        periodIndex > 0 
                        ? () => setState(() {
                          periodIndex--;
                          user.userData.settings.periodIndex = periodIndex;
                          sharedPreferences.setInt('periodIndex', periodIndex);
                        }) 
                        : null, 
                      color: Colors.white,
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                      )
                    ),
        
                    SCircularPercentIndicator.fromGrade(
                      Grade(grade: user.userData.getAverageGrade(periodIndex: periodIndex)),
                      context,
                      type: SCircularPercentIndicatorType.big
                    ),
        
                    IconButton(
                      onPressed: 
                        periodIndex < user.userData.settings.periodicity.parts - 1 
                        ? () => setState(() {
                          periodIndex++;
                          user.userData.settings.periodIndex = periodIndex;
                          sharedPreferences.setInt('periodIndex', periodIndex);
                        }) 
                        : null,
                      color: Colors.white, 
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                      )
                    )
                  ],
                ),
                const SizedBox(height: 15.0),
                Evolution(
                  a: 
                    gradesAmount >= 2 
                    ? user.userData.getAverageGradeEvolution(periodIndex: periodIndex).elementAt(gradesAmount - 2) 
                    : -1, 
                  b: user.userData.getAverageGrade(periodIndex: periodIndex), 
                  showBackground: true
                ),
                const SizedBox(height: 15.0),
                Text(
                  "${user.userData.settings.periodicity.displayName} ${periodIndex + 1}",
                  style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(
                      color: Colors.white
                    )
                )
              ],
            ),
            body: <Widget>[
              user.userData.disciplines.isEmpty
              ? const ErrorText(text: 'Aucune matière')
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.userData.disciplines.length,
                itemBuilder: (
                  BuildContext context, 
                  int index
                ) {
                  return DisciplineRowButton(
                    periodIndex: periodIndex,
                    discipline: user.userData.disciplines.elementAt(index),
                    disciplineIndex: index,
                  );
                },
              )
            ]
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // add discipline !!!!
              if (user.userData.disciplines.length >= AppProperties.maxAmountOfDisciplines) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('')
                  )
                );
                return;
              }

              final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
              final TextEditingController nameFieldController = TextEditingController();
              final TextEditingController abbreviationFieldController = TextEditingController();
              final TextEditingController coefficientFieldController = TextEditingController();
              coefficientFieldController.text = SMath.formatSignificantFigures(Grade().coefficient);
              
              showModalBottomSheet<dynamic>(
                context: context, 
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (
                      BuildContext context, 
                      StateSetter setModalState
                    ) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ModalBottomSheetLayout(
                          icon: Icons.add_rounded,
                          iconBackgroundColor: const Color.fromRGBO(109, 31, 118, 1),
                          title: 'Ajouter une matière',
                      
                          widgets: <Widget>[
                            Form(
                              key: formKey,
                              child: Column(
                                children: <Widget>[
                                  STextField(
                                    keyboardType: TextInputType.name,
                                    labelText: 'Nom',
                                    maxLength: AppProperties.maxDisciplineNameLength, 
                                    controller: nameFieldController, 
                                    validator: (String? value) {
                                      for (Discipline discipline in user.userData.disciplines) {
                                        if (discipline.name == value) {
                                          return 'Ce nom est déjà pris.';
                                        }
                                      }

                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer un nom.';
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10.0),
                                  STextField(
                                    keyboardType: TextInputType.name,
                                    labelText: 'Abbréviation', 
                                    maxLength: AppProperties.maxDisciplineAbbreviationLength,
                                    controller: abbreviationFieldController, 
                                    validator: (String? value) {
                                      for (Discipline discipline in user.userData.disciplines) {
                                        if (discipline.abbreviation == value) {
                                          return 'Cette abbréviation est déjà prise.';
                                        }
                                      }

                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer une abbréviation.';
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10.0),
                                  STextField(
                                    keyboardType: TextInputType.number,
                                    labelText: 'Coefficient', 
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(Regexes.twoDecimalsDouble)
                                    ],
                                    controller: coefficientFieldController, 
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer un coefficient.';
                                      }
                                    },
                                  )
                                ]
                              ),
                            )
                          ],
                      
                          onConfirm: () async {
                            // add discipline
                            if (formKey.currentState == null || !formKey.currentState!.validate()) {
                              return false;
                            }
    
                            Discipline createdDiscipline = Discipline(
                              name: nameFieldController.text,
                              abbreviation: abbreviationFieldController.text,
                              coefficient: double.parse(coefficientFieldController.text),
                              periods: List.generate(
                                user.userData.settings.periodicity.parts, 
                                (index) => Period()
                              )
                            );

                            user.userData.disciplines.add(createdDiscipline);
    
                            // save user to the database
                            SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                            if (result.failed) {
                              user.userData.disciplines.remove(createdDiscipline);
                              
                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return ErrorPopup(error: result);
                                },
                              );
                            } else {
                              // context.pop();
                            }
                            
                            return true;
                          }
                        )
                      );
                    }
                  );
                }
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.add_rounded,
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

class DisciplineRowButton extends StatelessWidget {
  final int periodIndex;
  final Discipline discipline;
  final int disciplineIndex;

  const DisciplineRowButton({
    super.key,

    required this.periodIndex,
    required this.discipline,
    required this.disciplineIndex
  });

  @override
  Widget build(BuildContext context) {
    final double disciplineAverageGrade = 
      discipline.getAverageGrade(periodIndex);

    final double disciplinePercentIndicatorAverageGrade = 
      discipline.getPercentIndicatorAverageGrade(periodIndex);
    
    final String disciplineDisplayAverageGrade =
      discipline.getDisplayAverageGrade(periodIndex);

    return Material(
      borderRadius: BorderRadius.circular(5.0),
      color: SColors.getBackgroundColor(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.0),
        onTap: () {
          // access to discipline
          context.go(
            '/averageGrade/disciplinePage', 
            extra: [disciplineIndex]
          );
        },
        onLongPress: () {
          // edit disciplineS !!
          context.go('/averageGrade/editDisciplinesPage');
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IntrinsicWidth(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            discipline.name,
                            style: Theme.of(context).textTheme.bodyLarge
                          ),
                          Wrap(
                            children: <Text>[
                              Text(
                                disciplineDisplayAverageGrade,
                                style: Theme.of(context).textTheme.bodyLarge
                              ),
                              if (discipline.coefficient != 1.0) ... {
                                Text(
                                  " ${SMath.formatSignificantFigures(discipline.coefficient)}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              }
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    LinearPercentIndicator(
                      padding: const EdgeInsets.all(0.0),
                      lineHeight: 3.0,
                      width: MediaQuery.of(context).size.width - 90,
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
              const Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
        ),
      ),
    );
  }
}

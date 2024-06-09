// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/discipline_pages/discipline_stats_page.dart';
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

class DisciplinePage extends StatefulWidget {
  final int disciplineIndex;

  const DisciplinePage({
    super.key,
    required this.disciplineIndex
  });

  @override
  State<DisciplinePage> createState() => _DisciplinePageState();
}

class _DisciplinePageState extends State<DisciplinePage> {
  int _selectedDestination = 0;

  int disciplineIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  void changeDisciplineIndex(int index) {
    disciplineIndex = index;
  }

  @override
  void initState() {
    disciplineIndex = widget.disciplineIndex;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    final List<Widget> pages = <Widget>[
      GradesPage(
        disciplineIndex: disciplineIndex,
        changeDisciplineIndexFunction: changeDisciplineIndex
      ),
      DisciplineStatsPage(
        disciplineIndex: disciplineIndex
      )
    ];

    final Discipline currentDiscipline = user.userData.disciplines.elementAt(disciplineIndex);
    final Period currentPeriod = currentDiscipline.periods.elementAt(user.userData.settings.periodIndex);

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
                [
                  const PopupMenuItem(
                    value: 'edit',
                    child: PopupMenuSingleItem(
                      text: 'Modifier',
                      icon: Icons.edit_rounded,
                    )
                  ),
                  const PopupMenuItem(
                    value: 'reorder',
                    child: PopupMenuSingleItem(
                      text: 'Trier',
                      icon: Icons.list_rounded,
                    )
                  ),
                  const PopupMenuItem(
                    value: 'empty',
                    child: PopupMenuSingleItem(
                      text: 'Vider',
                      icon: Icons.delete_rounded
                    )
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: PopupMenuSingleItem(
                      text: 'Supprimer', 
                      icon: Icons.not_interested_rounded
                    )
                  )
                ],
              onSelected: (String? value) {
                switch (value) {
                  case 'edit':
                    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
                    final TextEditingController nameFieldController = TextEditingController();
                    final TextEditingController abbreviationFieldController = TextEditingController();
                    final TextEditingController coefficientFieldController = TextEditingController();
                    nameFieldController.text = currentDiscipline.name;
                    abbreviationFieldController.text = currentDiscipline.abbreviation;
                    coefficientFieldController.text = SMath.formatSignificantFigures(currentDiscipline.coefficient);
                    
                    showModalBottomSheet<dynamic>(
                      context: context, 
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        // @override // TODO: possible to dispose that in a modalbottomsheet?
                        // void dispose() {
                        //   nameFieldController.dispose();
                        //   abbreviationFieldController.dispose();
                        //   coefficientFieldController.dispose();
                          
                        //   super.dispose(); 
                        // }
                        return StatefulBuilder(
                          builder: (
                            BuildContext context, 
                            StateSetter setModalState
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: ModalBottomSheetLayout(
                                icon: Icons.edit_rounded,
                                iconBackgroundColor: const Color.fromRGBO(109, 31, 118, 1),
                                title: 'Modifier une matière',
                            
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
                                              if (disciplineIndex == user.userData.disciplines.indexOf(discipline)) continue;

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
                                              if (disciplineIndex == user.userData.disciplines.indexOf(discipline)) continue;

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

                                  // if discipline didn't changed, don't save to the database, just close the popup

                                  final Discipline createdDiscipline = 
                                    Discipline(
                                      name: nameFieldController.text,
                                      abbreviation: abbreviationFieldController.text,
                                      coefficient: double.parse(coefficientFieldController.text),
                                      periods: currentDiscipline.periods
                                    );

                                  if (!currentDiscipline.compareTo(createdDiscipline)) {
                                    return true;
                                  }

                                  setState(() {
                                    user.userData.disciplines[disciplineIndex] = createdDiscipline;
                                  });
          
                                  // save user to the database
                                  SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                                  if (result.failed) {
                                    setState(() {
                                      user.userData.disciplines[disciplineIndex] = currentDiscipline;
                                    });

                                    showDialog(
                                      context: context, 
                                      builder: (BuildContext context) {
                                        return ErrorPopup(error: result);
                                      }
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
                    
                    break;
                  case 'reorder':
                    if (currentPeriod.grades.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez avoir ajouté au moins une note.')
                        )
                      );
                      break;
                    }

                    context.go(
                      '/averageGrade/disciplinePage/editDisciplinePage', 
                      extra: [disciplineIndex]
                    );
                    break;
                  case 'empty':
                    if (currentPeriod.grades.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez avoir ajouté au moins une note.'),
                        )
                      );

                      break;
                    }

                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return SConfirmationDialog(
                          icon: Icons.delete_rounded, 
                          iconBackgroundColor: Colors.red,
                          title: 'Suppression', 
                          content: 'Êtes-vous sûr de vouloir vider les notes de cette matière ?', 
                          cancelButtonTitle: 'Non',
                          onConfirm: () async {
                            final List<Grade> oldGrades = List<Grade>.from(currentPeriod.grades);

                            setState(() {
                              user.userData.disciplines.elementAt(disciplineIndex).periods.elementAt(user.userData.settings.periodIndex).grades = [];
                            });

                            SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                            
                            if (result.failed) {
                              setState(() {
                                user.userData.disciplines.elementAt(disciplineIndex).periods.elementAt(user.userData.settings.periodIndex).grades = oldGrades;
                              });

                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return ErrorPopup(error: result);
                                }
                              );
                            } else {
                              // context.pop();
                            }
                          }
                        );
                      },
                    );
                    break;
                  case 'delete':
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return SConfirmationDialog(
                          icon: Icons.delete_rounded, 
                          iconBackgroundColor: Colors.red,
                          title: 'Suppression', 
                          content: 'Êtes-vous sûr de vouloir supprimer cette matière ?', 
                          cancelButtonTitle: 'Non',
                          onConfirm: () async {
                            context.pop();
                            Discipline oldDiscipline = user.userData.disciplines.removeAt(disciplineIndex);

                            SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                            
                            if (result.failed) {
                              user.userData.disciplines.insert(disciplineIndex, oldDiscipline);

                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return ErrorPopup(error: result);
                                }
                              );
                            } else {
                              // context.go('/averageGrade');
                            }
                          }
                        );
                      },
                    );
                    break;
                  default:
                    break;
                }
              },
            )
          }
        ],
      ),
      body: pages.elementAt(_selectedDestination),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.list_rounded), 
            label: 'Notes'
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

class GradesPage extends StatefulWidget {
  final int disciplineIndex;
  final Function(int) changeDisciplineIndexFunction;

  const GradesPage({
    super.key,
    required this.disciplineIndex,
    required this.changeDisciplineIndexFunction
  });

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  int disciplineIndex = 0;

  void _goToPreviousDiscipline() {
    setState(() {
      disciplineIndex--;
    });

    widget.changeDisciplineIndexFunction(disciplineIndex);
  }

  void _goToNextDiscipline() {
    setState(() {
      disciplineIndex++;
    });
    widget.changeDisciplineIndexFunction(disciplineIndex);
  }

  @override
  void initState() {
    disciplineIndex = widget.disciplineIndex;
    
    super.initState();
  }

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

        final int disciplinesAmount = user.userData.disciplines.length;
        final Discipline discipline = 
          disciplineIndex < disciplinesAmount 
          ? user.userData.disciplines.elementAt(disciplineIndex) 
          : Discipline(periods: List<Period>.generate(3, (int index) => Period()));
        
        final Period currentPeriod = discipline.periods.elementAt(user.userData.settings.periodIndex);
        final int gradesAmount = currentPeriod.grades.length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: DefaultPageLayout(
            leading: Column(
              children: <Widget>[
                Column(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: disciplineIndex > 0 ? _goToPreviousDiscipline : null, 
                          color: Colors.white,
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                          )
                        ),
        
                        SCircularPercentIndicator.fromGrade(
                          Grade(grade: discipline.getAverageGrade(user.userData.settings.periodIndex)),
                          context,
                          type: SCircularPercentIndicatorType.big
                        ),
        
                        IconButton(
                          onPressed: disciplineIndex < disciplinesAmount - 1 ? _goToNextDiscipline : null, 
                          color: Colors.white,
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                          )
                        )
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
              currentPeriod.grades.isEmpty
              ? const ErrorText(text: 'Aucune note')
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentPeriod.grades.length,
                itemBuilder: (
                  BuildContext context, 
                  int index
                ) {
                  return NoteRowButton(
                    disciplineIndex: disciplineIndex,
                    grade: currentPeriod.grades.elementAt(index),
                    gradeIndex: index,
                  );
                },
              )
            ]
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final GlobalKey<FormState> formKey = GlobalKey<FormState>();

              DateTime date = DateTime.now();
              final dateFieldController = TextEditingController();
              
              String gradeType = GradeType.supervisedHomework.detailedDisplayName;
              final TextEditingController subjectFieldController = TextEditingController();

              final TextEditingController gradeFieldController = TextEditingController();
              final TextEditingController maxGradeFieldController = TextEditingController();
              final TextEditingController coefficientFieldController = TextEditingController();
              maxGradeFieldController.text = SMath.formatSignificantFigures(Grade().maxGrade);
              coefficientFieldController.text = SMath.formatSignificantFigures(Grade().coefficient);

              bool isGradeSignificative = true;
              
              showModalBottomSheet<dynamic>(
                context: context, 
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (
                      BuildContext context, 
                      StateSetter setModalState
                    ) {
                      dateFieldController.text = DateFormat('dd/MM/yyyy').format(date);
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ModalBottomSheetLayout(
                          icon: Icons.add_rounded,
                          iconBackgroundColor: const Color.fromRGBO(109, 31, 118, 1),
                          title: 'Ajouter une note',
                      
                          widgets: <Widget>[
                            Form(
                              key: formKey,
                              child: Column(
                                children: <Widget>[
                                  Flex(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      Flexible(
                                        child: STextField(
                                          keyboardType: TextInputType.number,
                                          labelText: 'Note', 
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(Regexes.twoDecimalsDouble)
                                          ],
                                          controller: gradeFieldController, 
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer une note.';
                                            }

                                            if (double.parse(value) > double.parse(maxGradeFieldController.text)) {
                                              return 'Veuillez entrer une note valide.';
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Flexible(
                                        flex: 2,
                                        child: STextField(
                                          keyboardType: TextInputType.number,
                                          labelText: 'Note maximum', 
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(Regexes.twoDecimalsDouble)
                                          ],
                                          controller: maxGradeFieldController, 
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer une note maximum.';
                                            }

                                            if (double.parse(value) < double.parse(gradeFieldController.text)) {
                                              return 'Veuillez entrer une note maximum valide.';
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Flexible(
                                        child: STextField(
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

                                            if (double.parse(value) <= 0.0) {
                                              return 'Veuillez entrer un coefficient valide.';
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Flex(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      Flexible(
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                              borderSide: const BorderSide(
                                                width: 2,
                                                color: Color.fromRGBO(206, 206, 206, 1),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                              borderSide: const BorderSide(
                                                width: 2,
                                                color: Color.fromRGBO(206, 206, 206, 1),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                              borderSide: const BorderSide(
                                                width: 2,
                                                color: Color.fromRGBO(206, 206, 206, 1),
                                              ),
                                            )
                                          ),
                                          value: gradeType,
                                          icon: const Icon(Icons.arrow_drop_down_rounded),
                                          onChanged: (String? value) {
                                            setModalState(() {
                                              gradeType = value ?? '';
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(15.0),
                                          isExpanded: true,
                                          items: GradeType.values.map((type) {
                                            return DropdownMenuItem(
                                              value: type.detailedDisplayName,
                                              child: Text(
                                                type.detailedDisplayName,
                                                style: Theme.of(context).textTheme.bodyLarge,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Flexible(
                                        flex: 2,
                                        child: STextField(
                                          keyboardType: TextInputType.name,
                                          labelText: 'Sujet', 
                                          controller: subjectFieldController, 
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer un sujet.';
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Flex(
                                    direction: Axis.horizontal,
                                    children: <Flexible>[
                                      Flexible(
                                        child: STextField(
                                          keyboardType: TextInputType.none,
                                          labelText: 'Date', 
                                          controller: dateFieldController, 
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez sélectionner une date.';
                                            }
                                          },
                                          onTap: () async {
                                            final DateTime? selectedDate = await showDatePicker(
                                              context: context, 
                                              initialDate: date, 
                                              firstDate: DateTime(2023), 
                                              lastDate: DateTime(2069)
                                            );

                                            if (selectedDate != null) {
                                              setModalState(() {
                                                date = selectedDate;
                                              });
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  SwitchListTile.adaptive(
                                    value: isGradeSignificative, 
                                    onChanged: (value) {
                                      setModalState(() {
                                        isGradeSignificative = value;
                                      });
                                    },
                                    title: Text(
                                      'Significatif',
                                      style: Theme.of(context).textTheme.bodyMedium
                                    ),
                                    dense: true,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  ),
                                ]
                              ),
                            )
                          ],
                      
                          onConfirm: () async {
                            if (formKey.currentState == null || !formKey.currentState!.validate()) {
                              return false;
                            }

                            final double grade = double.parse(gradeFieldController.text);
                            final double maxGrade = double.parse(maxGradeFieldController.text);
                            final double coefficient = double.parse(coefficientFieldController.text);

                            final DateTime now = DateTime.now();
                            final DateTime creationDate = 
                              DateFormat('dd/MM/yyyy')
                                .parse(dateFieldController.text)
                                .add(
                                  Duration(
                                    hours: now.hour,
                                    minutes: now.minute,
                                    seconds: now.second
                                  )
                                );

                            final Grade createdGrade = Grade(
                              grade: grade,
                              maxGrade: maxGrade,
                              coefficient: coefficient,
                              creationDate: creationDate,
                              type: GradeType.values.firstWhere((type) => type.detailedDisplayName == gradeType),
                              subject: subjectFieldController.text,
                              isSignificative: isGradeSignificative
                            );

                            currentPeriod.grades.add(createdGrade);

                            // save user to the database
                            SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                            if (result.failed) {
                              currentPeriod.grades.remove(createdGrade);
                              
                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return ErrorPopup(error: result);
                                },
                              );
                            } else {
                              // GetIt.I.registerSingleton<SUser>(user);
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

class NoteRowButton extends StatelessWidget {
  final int disciplineIndex;
  final Grade grade;
  final int gradeIndex;

  const NoteRowButton({
    super.key,

    required this.disciplineIndex,
    required this.grade,
    required this.gradeIndex
  });

  @override
  Widget build(BuildContext context) {
    // final SUser user = GetIt.I.get<SUser>();

    return Material(
      borderRadius: BorderRadius.circular(5.0),
      color: SColors.getBackgroundColor(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.0),
        onTap: () {
          // access to grade
          context.go(
            '/averageGrade/disciplinePage/gradePage', 
            extra: [
              disciplineIndex,
              gradeIndex
            ]
          );
        },
        onLongPress: () {
          // edit grades
          context.go(
            '/averageGrade/disciplinePage/editDisciplinePage', 
            extra: [disciplineIndex]
          );
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
                            "${grade.type.displayName} du ${DateFormat('dd/MM/yyyy').format(grade.creationDate!)}",
                            style: Theme.of(context).textTheme.bodyLarge
                          ),
                          Wrap(
                            children: <Text>[
                              Text(
                                grade.display,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              if (grade.coefficient != 1.0) ... {
                                Text(
                                  " ${SMath.formatSignificantFigures(grade.coefficient)}",
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
                      percent: grade.toPercentage,
                      backgroundColor: Colors.grey.shade300,
                      progressColor: grade.color,
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
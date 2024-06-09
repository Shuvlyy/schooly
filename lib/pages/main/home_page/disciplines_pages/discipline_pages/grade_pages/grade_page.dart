// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/buttons/appbar_popup_menu_button.dart';
import 'package:schooly/widgets/clickable_info.dart';
import 'package:schooly/widgets/evolution.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/percent_indicators/scircular_percent_indicator.dart';
import 'package:schooly/widgets/popup_menu_single_item.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/popups/modal_bottom_sheet_layout.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/textfields/text_field.dart';

class GradePage extends StatefulWidget {
  final int disciplineIndex;
  final int gradeIndex;

  const GradePage({
    super.key,

    required this.disciplineIndex,
    required this.gradeIndex
  });

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  int gradeIndex = 0;

  void _goToPreviousGrade() {
    setState(() {
      gradeIndex--;
    });
  }

  void _goToNextGrade() {
    setState(() {
      gradeIndex++;
    });
  }

  @override
  void initState() {
    gradeIndex = widget.gradeIndex;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    final Discipline discipline = user.userData.disciplines.elementAt(widget.disciplineIndex);
    final Period period = discipline.periods.elementAt(user.userData.settings.periodIndex);
    final Grade grade = period.grades.elementAt(gradeIndex);

    final List<double> averageGradeEvolution = user.userData.getAverageGradeEvolution();
    final List<Grade> gradesSortedByDate = user.userData.getGradesSortedByDate();

    final int gradeGeneralIndex = gradesSortedByDate.indexOf(grade);
    final double averageAtX = averageGradeEvolution.elementAt(gradeGeneralIndex);
    final double averageAtXMinus1 = gradeGeneralIndex == 0 ? -1 : averageGradeEvolution.elementAt(gradeGeneralIndex - 1);

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
        actions: [
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

                  final TextEditingController gradeFieldController = TextEditingController();
                  final TextEditingController maxGradeFieldController = TextEditingController();
                  final TextEditingController coefficientFieldController = TextEditingController();

                  String gradeType = grade.type.detailedDisplayName;
                  final TextEditingController subjectFieldController = TextEditingController();

                  DateTime date = grade.creationDate!;
                  final dateFieldController = TextEditingController();

                  gradeFieldController.text = SMath.formatSignificantFigures(grade.grade);
                  maxGradeFieldController.text = SMath.formatSignificantFigures(grade.maxGrade);
                  coefficientFieldController.text = SMath.formatSignificantFigures(grade.coefficient);

                  subjectFieldController.text = grade.subject;

                  bool isGradeSignificative = grade.isSignificative;
                  
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
                              icon: Icons.edit_rounded,
                              iconBackgroundColor: const Color.fromRGBO(109, 31, 118, 1),
                              title: 'Modifier une note',
                          
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

                                final Grade oldGrade = period.grades.elementAt(gradeIndex);

                                final double g = double.parse(gradeFieldController.text);
                                final double maxG = double.parse(maxGradeFieldController.text);
                                final double coef = double.parse(coefficientFieldController.text);

                                final GradeType gType = GradeType.values.firstWhere((GradeType t) => t.detailedDisplayName == gradeType);

                                final DateTime cDate = 
                                  DateFormat('dd/MM/yyyy')
                                    .parse(dateFieldController.text)
                                    .add(
                                      Duration(
                                        hours: grade.creationDate!.hour,
                                        minutes: grade.creationDate!.minute,
                                        seconds: grade.creationDate!.second
                                      )
                                    );

                                final Grade createdGrade = Grade(
                                  grade: g,
                                  maxGrade: maxG,
                                  coefficient: coef,
                                  creationDate: cDate,
                                  type: gType,
                                  subject: subjectFieldController.text,
                                  isSignificative: isGradeSignificative
                                );

                                period.grades[gradeIndex] = createdGrade;

                                // save user to the database
                                SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                                if (result.failed) {
                                  setState(() {
                                    period.grades[gradeIndex] = oldGrade;
                                  });
                                  
                                  showDialog(
                                    context: context, 
                                    builder: (BuildContext context) {
                                      return ErrorPopup(error: result);
                                    },
                                  );
                                } else {
                                  setState(() {});
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
                  break;
                case 'delete':
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return SConfirmationDialog(
                        icon: Icons.delete_rounded, 
                        iconBackgroundColor: Colors.red,
                        title: 'Suppression', 
                        content: 'Êtes-vous sûr de vouloir supprimer cette note ?', 
                        cancelButtonTitle: 'Non',
                        onConfirm: () async {
                          context.pop();
                          Grade oldGrade = period.grades.removeAt(gradeIndex);

                          SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
                          
                          if (result.failed) {
                            period.grades.insert(gradeIndex, oldGrade);

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
            }
          )
        ],
      ),
      body: DefaultPageLayout(
        // padding: 50,
        expandedBody: false,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "${discipline.name} • #${gradeIndex + 1}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  "${grade.type.displayName} • ${grade.subject}",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 20.0),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: IconButton(
                        onPressed: gradeIndex > 0 ? _goToPreviousGrade : null, 
                        color: Colors.white,
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                        )
                      ),
                    ),
    
                    SCircularPercentIndicator.fromGrade(
                      grade,
                      context,
                      type: SCircularPercentIndicatorType.veryBig
                    ),
    
                    Flexible(
                      child: IconButton(
                        onPressed: gradeIndex < period.grades.length - 1 ? _goToNextGrade : null,
                        color: Colors.white, 
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded
                        )
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            if (gradeIndex == 0) ... {
              Evolution(
                a: -1,
                showBackground: true,
                isNotSignificative: !grade.isSignificative,
              )
            } else ... {
              Evolution(
                a: period.getAverageGradeAtTMinus(period.grades.length - gradeIndex),
                b: period.getAverageGradeAtTMinus(period.grades.length - gradeIndex - 1), 
                showBackground: true,
                isNotSignificative: !grade.isSignificative,
              )
            }
          ]
        ),
        autoSpacing: false,
        body: <Widget>[
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClickableInfo(
                title: 'Coefficient', 
                subtitle: SMath.formatSignificantFigures(grade.coefficient)
              ),
              const InfoSeparator(),
              ClickableInfo(
                title: 'Type', 
                subtitle: grade.type.displayName
              ),
              const InfoSeparator(),
              Material(
                color: SColors.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(10.0),
                child: Tooltip(
                  message: DateFormat('dd/MM/yyyy hh:mm:ss', 'fr-FR').format(grade.creationDate!),
                  child: ClickableInfo(
                    title: 'Date', 
                    subtitle: DateFormat.yMMMMd('fr-FR').format(grade.creationDate!),
                    onTap: () {},
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Effet sur la moyenne générale',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600
                )
              ),
              // const SizedBox(height: 5.0),
              Evolution(
                a: averageAtXMinus1,
                b: averageAtX,
                size: EvolutionSize.big,
              )
            ],
          ),
          // if (...) ... [ // TODO: If user is in a class group and that the selected grade is a class-wide grade
          //   const SizedBox(height: 10.0),
          //   const Separator(),
          //   const SizedBox(height: 10.0),
          //   const Flex(
          //     direction: Axis.horizontal,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       ClickableInfo(
          //         title: 'Min.', 
          //         subtitle: '0.0'
          //       ),
          //       const InfoSeparator(),
          //       ClickableInfo(
          //         title: 'Moyenne', 
          //         subtitle: '10.0'
          //       ),
          //       const InfoSeparator(),
          //       ClickableInfo(
          //         title: 'Max.', 
          //         subtitle: '20.0'
          //       ),
          //     ],
          //   )
          // ]
        ]
      )
    );
  }
}

class InfoSeparator extends StatelessWidget {
  const InfoSeparator({ super.key });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 2.0,
        height: 16.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(1.0)
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/widgets/error_text.dart';
import 'package:schooly/widgets/legend.dart';
import 'package:schooly/widgets/popups/modal_bottom_sheet_layout.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/clickable_tile.dart';
import 'package:schooly/widgets/vertical_switch_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisciplineStatsPage extends StatefulWidget {
  final int disciplineIndex;
  
  const DisciplineStatsPage({
    super.key,
    required this.disciplineIndex
  });

  @override
  State<DisciplineStatsPage> createState() => _DisciplineStatsPageState();
}

class _DisciplineStatsPageState extends State<DisciplineStatsPage> with TickerProviderStateMixin {
  final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

  bool firstLoading = true;

  final List<String> _destinations = <String>[
    'Courbe',
    'Moyenne',
    'Diagramme circulaire'
  ];

  late TabController _tabController;

  final List<List> gradesLegends = <List>[
    [Colors.red, '< 10', false],
    [Colors.orange, '10-12', false],
    [Colors.yellow, '12-14', false],
    [Colors.lightGreen, '14-16', false],
    [Colors.green, '< 20', false],
    [Colors.green.shade700, '20', false]
  ];

  List<bool> showLegend = List<bool>.generate(6, (index) => false);

  bool lineChartIsCurved = false;
  bool lineChartShowCurrentAverage = false;
  List<bool> lineChartShowPeriodAverageGrade = <bool>[];
  List<Color> lineChartShowPeriodAverageGradeColors = 
    <Color>[
      Colors.deepPurple,
      Colors.pink,
      Colors.red
    ];
  bool lineChartShowAverageEvolution = false;
  bool lineChartDynamicYAxis = false;
  bool lineChartShowGradesTrendLine = false;
  bool lineChartShowAverageGradeTrendLine = false;
  bool lineChartShowGradientBelowBar = false;
  bool lineChartShowLegends = false;

  bool pieChartFirstLoading = true;
  int pieChartTouchedIndex = -1;

  bool pieChartCountNonSignificativeGrades = true;

  @override
  void initState() {
    _tabController = TabController(length: _destinations.length, vsync: this);
    
    for (String pref in <String>[
      'DElineChartIsCurved', 
      'DElineChartShowCurrentAverage',
      'DElineChartShowAverageEvolution',
      'DElineChartDynamicYAxis',
      'DElineChartShowGradesTrendLine',
      'DElineChartShowAverageGradeTrendLine',
      'DElineChartShowGradientBelowBar',
      'DElineChartShowLegends'
    ]) {
      if (sharedPreferences.getBool(pref) == null) {
        sharedPreferences.setBool(pref, true);
      }
    }

    setState(() {
      lineChartIsCurved = sharedPreferences.getBool('DElineChartIsCurved')!;
      lineChartShowCurrentAverage = sharedPreferences.getBool('DElineChartShowCurrentAverage')!;
      lineChartShowAverageEvolution = sharedPreferences.getBool('DElineChartShowAverageEvolution')!;
      lineChartDynamicYAxis = sharedPreferences.getBool('DElineChartDynamicYAxis')!;
      lineChartShowGradesTrendLine = sharedPreferences.getBool('DElineChartShowGradesTrendLine')!;
      lineChartShowAverageGradeTrendLine = sharedPreferences.getBool('DElineChartShowAverageGradeTrendLine')!;
      lineChartShowGradientBelowBar = sharedPreferences.getBool('DElineChartShowGradientBelowBar')!;
      lineChartShowLegends = sharedPreferences.getBool('DElineChartShowLegends')!;
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
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

        final Discipline discipline = user.userData.disciplines.elementAt(widget.disciplineIndex);
        final int periodIndex = user.userData.settings.periodIndex;
        final Period currentPeriod = discipline.periods.elementAt(periodIndex);
        final int gradesAmount = currentPeriod.grades.length;
        final Periodicity userPeriodicity = user.userData.settings.periodicity;

        if (firstLoading) {
          lineChartShowPeriodAverageGrade = List<bool>.generate(
            userPeriodicity.parts, 
            (int index) => index == periodIndex
          );

          firstLoading = false;
        }

        List<Grade> sortedGrades = List<Grade>.from(currentPeriod.grades)
          ..addAll([
            for (int k = 0; k < lineChartShowPeriodAverageGrade.length; k++) ... {
              if (lineChartShowPeriodAverageGrade[k]) ... {
                Grade(
                  grade: discipline.getAverageGrade(k)
                )
              }
            }
          ])
          ..sort((Grade a, Grade b) => a.toPercentage.compareTo(b.toPercentage));

        double minY = 0;
        double maxY = 20;

        if (lineChartDynamicYAxis) {
          minY = sortedGrades.first.toPercentage * 20 <= 1 ? 0 : sortedGrades.first.toPercentage * 20 - 1;
          maxY = sortedGrades.last.toPercentage * 20 >= 19 ? 20 : sortedGrades.last.toPercentage * 20 + 1;
        }
        
        List<LineChartBarData> lineChartBarData = <LineChartBarData>[
          LineChartBarData(
            isCurved: lineChartIsCurved,
            color: Theme.of(context).primaryColor,
            barWidth: 4.0,
            preventCurveOverShooting: true,
            belowBarData: 
              lineChartShowGradientBelowBar
              ? BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: List<Color>.generate(
                    (maxY - minY).toInt(), 
                    (int index) {
                      return Grade(grade: index.toDouble() + minY).color.withOpacity(0.3);
                    }
                  )
                )
              )
              : null,
            spots: List<FlSpot>.generate(
              gradesAmount, 
              (int index) {
                return FlSpot(index.toDouble(), currentPeriod.grades.elementAt(index).toPercentage * 20);
              }
            )
          ),
        ];

        List<HorizontalLine> lineChartHorizontalLines = <HorizontalLine>[];

        List<Legend> lineChartShownLegends = <Legend>[
          Legend(
            color: Theme.of(context).primaryColor,
            title: 'Notes',
          )
        ];

        if (lineChartShowCurrentAverage) {
          for (int k = 0; k < lineChartShowPeriodAverageGrade.length; k++) {
            if (lineChartShowPeriodAverageGrade[k]) {
              double selectedPeriodAverageGrade = discipline.getAverageGrade(k);

              if (selectedPeriodAverageGrade == -1.0) {
                selectedPeriodAverageGrade = 0.0;
              }

              lineChartHorizontalLines.add(
                HorizontalLine(
                  y: selectedPeriodAverageGrade,
                  color: lineChartShowPeriodAverageGradeColors[k],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: Theme.of(context).textTheme.bodyMedium,
                    labelResolver: (HorizontalLine hLine) {
                      return "${userPeriodicity.displayName[0]}${k+1} : ${SMath.formatSignificantFigures(selectedPeriodAverageGrade)}";
                    },
                  )
                )
              );

              lineChartShownLegends.add(
                Legend(
                  title: "Moyenne ${userPeriodicity.displayName[0]}${k+1}",
                  color: lineChartShowPeriodAverageGradeColors[k],
                )
              );
            }
          }
        }

        if (lineChartShowAverageEvolution) {
          lineChartBarData.add(
            LineChartBarData(
              isCurved: lineChartIsCurved,
              color: 
                gradesAmount > 1 
                ? null 
                : Grade(grade: currentPeriod.getAverageGrade).color,
              gradient: 
                gradesAmount > 1 
                ? LinearGradient(
                  colors: 
                    List<Color>.generate(
                      gradesAmount, 
                      (int index) {
                        return Grade(grade: currentPeriod.getAverageGradeAtT(index)).color;
                      }
                    )
                  )
                : null,
              barWidth: 2.0,
              preventCurveOverShooting: true,                            
              spots: List<FlSpot>.generate(
                gradesAmount, 
                (int index) {
                  return FlSpot(index.toDouble(), currentPeriod.getAverageGradeAtT(index));
                }
              )
            )
          );

          lineChartShownLegends.add(
            Legend(
              title: 'Évolution de la moyenne',
              color: Grade(grade: currentPeriod.getAverageGrade).color,
            )
          );
        }
      
        if (lineChartShowGradesTrendLine) {
          List<double> x = List<double>.generate(gradesAmount, (int index) => index.toDouble());
          List<double> y = List<double>.generate(gradesAmount, (int index) => currentPeriod.grades.elementAt(index).toPercentage * 20);

          List<double> trendLine = SMath.calculateTrendLine(x, y);

          lineChartBarData.add(
            LineChartBarData(
              color: const Color.fromRGBO(204, 204, 255, 1),
              barWidth: 2.0,
              dotData: const FlDotData(
                show: false
              ),
              spots: List<FlSpot>.generate(
                gradesAmount, 
                (int index) {
                  return FlSpot(index.toDouble(), trendLine[0] + (trendLine[1] * index));
                }
              )
            )
          );

          lineChartShownLegends.add(
            const Legend(
              title: 'Évolution générale des notes', 
              color: Color.fromRGBO(204, 204, 255, 1)
            )
          );
        }

        if (lineChartShowAverageGradeTrendLine) {
          List<double> x = List<double>.generate(gradesAmount, (int index) => index.toDouble());
          List<double> y = List<double>.generate(gradesAmount, (int index) => currentPeriod.getAverageGradeAtT(index));

          List<double> trendLine = SMath.calculateTrendLine(x, y);

          lineChartBarData.add(
            LineChartBarData(
              color: const Color.fromRGBO(255, 204, 153, 1),
              barWidth: 2.0,
              dotData: const FlDotData(
                show: false
              ),
              spots: List<FlSpot>.generate(
                gradesAmount, 
                (int index) {
                  return FlSpot(index.toDouble(), trendLine[0] + (trendLine[1] * index));
                }
              )
            )
          );

          lineChartShownLegends.add(
            const Legend(
              title: 'Évolution générale de la moyenne',
              color: Color.fromRGBO(255, 204, 153, 1),
            )
          );
        }

        if (!lineChartShowLegends) {
          lineChartShownLegends.clear();
        }

        final Widget lineChartPage =
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles()
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles()
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles()
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32
                          )
                        )
                      ),
                      borderData: FlBorderData(
                        border: Border(
                          left: BorderSide(
                            color: SColors.getInvertedBackgroundColor(context),
                            width: 2.0
                          )
                        )
                      ),
                      gridData: const FlGridData(
                        drawVerticalLine: false
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black.withOpacity(0.75),
                          tooltipRoundedRadius: 10,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            final int x = touchedSpots[0].x.toInt();
                            final Grade touchedGrade = currentPeriod.grades.elementAt(x);
                            final String gradeTitle = "${touchedGrade.type.displayName} du ${DateFormat('dd/MM/yyyy').format(touchedGrade.creationDate!)}\n";
                            final double averageAtX = currentPeriod.getAverageGradeAtT(x);
                            // final double averageAtXMinus1 = x > 0 ? currentPeriod.getAverageGradeAtT(x - 1) : -1;

                            return [
                              LineTooltipItem(
                                gradeTitle,
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.white
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: touchedGrade.display,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: touchedGrade.color
                                    )
                                  ),
                                  if (touchedGrade.coefficient != 1.0) ... {
                                    TextSpan(
                                      text: "\nCoef. : ${SMath.formatSignificantFigures(touchedGrade.coefficient)}",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: touchedGrade.color,
                                      ),
                                    )
                                  },
                                  if (lineChartShowAverageEvolution) ... {
                                    TextSpan(
                                      text: '\n‎              ‎',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        // color: SColors.getGreyscaleColor(context),
                                        color: Colors.white,
                                        // fontFeatures: <FontFeature>[
                                        //   FontFeature.
                                        // ]
                                        decoration: TextDecoration.lineThrough
                                      )
                                    )
                                  }
                                ],
                              ),
                              if (lineChartShowAverageEvolution) ... {
                                LineTooltipItem(
                                  'Moyenne\n',
                                  Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: SMath.formatSignificantFigures(averageAtX),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Grade(grade: averageAtX).color
                                      ),
                                      // children: <InlineSpan>[
                                      //   WidgetSpan(
                                      //     child: Evolution(
                                      //       a: averageAtXMinus1,
                                      //       b: averageAtX,
                                      //       onlySymbol: true,
                                      //     )
                                      //   )
                                      // ]
                                    ),
                                  ],
                                ),
                              },
                              if (lineChartShowGradesTrendLine) ... {
                                const LineTooltipItem(
                                  '',
                                  TextStyle(fontSize: 0.0)
                                )
                              },
                              if (lineChartShowAverageGradeTrendLine) ... {
                                const LineTooltipItem(
                                  '',
                                  TextStyle(fontSize: 0.0)
                                )
                              }
                            ];
                          },
                        )
                      ),
                      lineBarsData: lineChartBarData,
                      extraLinesData: ExtraLinesData(
                        horizontalLines: lineChartHorizontalLines
                      ),

                    )
                  )
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Wrap>[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: lineChartShownLegends,
                  )
                ],
              ),

              const Separator(),

              ClickableTile(
                icon: Icons.settings_rounded,
                iconBackgroundColor: const Color.fromRGBO(216, 191, 216, 1),
                title: 'Options',
                onTap: () {
                  showModalBottomSheet(
                    context: context, 
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (
                          BuildContext context, 
                          Function(Function()) setModalState
                        ) {
                          return ModalBottomSheetLayout(
                            title: 'Options',
                            // description: ,
                            icon: Icons.settings_rounded,
                            iconBackgroundColor: const Color.fromRGBO(216, 191, 216, 1),
                            showActions: false,
                            
                            widgets: <Widget>[
                              SwitchListTile.adaptive(
                                value: lineChartIsCurved, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartIsCurved = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartIsCurved', value);
                                },
                                title: Text(
                                  'Lisser la courbe',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              const Separator(),

                              SwitchListTile.adaptive(
                                value: lineChartShowCurrentAverage, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowCurrentAverage = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowCurrentAverage', value);
                                },
                                title: Text(
                                  'Afficher la moyenne actuelle',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),
                              
                              if (lineChartShowCurrentAverage) ... {
                                Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Flexible>[
                                    for (int k = 0 ; k < userPeriodicity.parts; k++) ... {
                                      Flexible(
                                        child: VerticalSwitchListTile(
                                          value: lineChartShowPeriodAverageGrade[k],
                                          title: "${userPeriodicity.displayName} ${k+1}",
                                          color: lineChartShowPeriodAverageGradeColors[k],
                                          showBackground: false,
                                          onChanged: (bool value) {
                                            setState(() {
                                              lineChartShowPeriodAverageGrade[k] = value;
                                            });
                                          }
                                        )
                                      )
                                    }
                                  ]
                                )
                              },
                              
                              const Separator(),

                              SwitchListTile.adaptive(
                                value: lineChartShowAverageEvolution, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowAverageEvolution = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowAverageEvolution', value);
                                },
                                title: Text(
                                  'Afficher l\'évolution de la moyenne',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              SwitchListTile.adaptive(
                                value: lineChartDynamicYAxis, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartDynamicYAxis = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartDynamicYAxis', value);
                                },
                                title: Text(
                                  'Axe des ordonnées dynamique',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              SwitchListTile.adaptive(
                                value: lineChartShowGradesTrendLine, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowGradesTrendLine = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowGradesTrendLine', value);
                                },
                                title: Text(
                                  'Afficher l\'évolution générale des notes',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              SwitchListTile.adaptive(
                                value: lineChartShowAverageGradeTrendLine, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowAverageGradeTrendLine = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowAverageGradeTrendLine', value);
                                },
                                title: Text(
                                  'Afficher l\'évolution générale de la moyenne',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              SwitchListTile.adaptive(
                                value: lineChartShowGradientBelowBar, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowGradientBelowBar = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowGradientBelowBar', value);
                                },
                                title: Text(
                                  'Afficher le dégradé',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              const Separator(),

                              SwitchListTile.adaptive(
                                value: lineChartShowLegends, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartShowLegends = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DElineChartShowLegends', value);
                                },
                                title: Text(
                                  'Afficher la légende',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              )
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );

        final Widget averageBarChartPage = Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Soon...',
              style: Theme.of(context).textTheme.displayMedium,
            )
          ],
        );

        final List<List<Grade>> gradesSplittedIntoRange = 
          currentPeriod.getGradesSplittedIntoRange(
            countNonSignificativeGrades: pieChartCountNonSignificativeGrades
          );
        
        final int touchedPartLength = pieChartTouchedIndex >= 0 ? gradesSplittedIntoRange[pieChartTouchedIndex].length : 0;
        final int pieChartGradesAmount = currentPeriod.getGradesAmount(countNonSignificativeGrades: pieChartCountNonSignificativeGrades);
        
        final Widget circularChartPage =
          gradesAmount > 0
          ? Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event, 
                            PieTouchResponse? pieTouchResponse
                          ) {
                            setState(() {
                              if (
                                !event.isInterestedForInteractions
                                || pieTouchResponse == null 
                                || pieTouchResponse.touchedSection == null
                                // || pieTouchResponse.touchedSection?.touchedSectionIndex == pieChartTouchedIndex
                              ) {
                                pieChartTouchedIndex = -1;
                                return;
                              }

                              pieChartTouchedIndex = gradesLegends.indexWhere(
                                (List element) => 
                                  (element[0] as Color).value == pieTouchResponse.touchedSection?.touchedSection?.color.value
                              );
                            });
                          }
                        ),
                        borderData: FlBorderData(
                          show: false
                        ),
                        centerSpaceRadius: 110,
                        sectionsSpace: 0,
                        sections: List<PieChartSectionData>.generate(6, (index) {
                          final bool isTouched = index == pieChartTouchedIndex;
                          final double percentage = gradesSplittedIntoRange[index].length / pieChartGradesAmount * 100;
                
                          if (percentage > 0.0) {
                            showLegend[index] = true;
                          }
                
                          return PieChartSectionData(
                            color: gradesLegends[index][0],
                            value: percentage,
                            title: '',
                            radius: isTouched ? 60 : 50
                          );
                        })
                      )
                    )
                  ),
                  Column(
                    children: <Text>[
                      if (pieChartTouchedIndex >= 0) ... {
                        Text(
                          "${SMath.formatSignificantFigures(touchedPartLength / pieChartGradesAmount * 100)}%",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          "$touchedPartLength/$pieChartGradesAmount",
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      }
                    ]
                  )
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Wrap>[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: <Legend>[
                      for (int k = 0; k < showLegend.length; k++) ... {
                        if (showLegend[k]) ... {
                          Legend(
                            color: gradesLegends[k][0],
                            title: gradesLegends[k][1],
                          )
                        }
                      },
                    ]
                  ),
                ],
              ),

              const SizedBox(height: 10.0),

              const Separator(),

              Material(
                color: SColors.getBackgroundColor(context),
                child: SwitchListTile.adaptive(
                  value: pieChartCountNonSignificativeGrades, 
                  onChanged: (value) {
                    setState(() {
                      pieChartCountNonSignificativeGrades = value;
                    });

                    sharedPreferences.setBool('DEpieChartCountNonSignificativeGrades', value);
                  },
                  title: Text(
                    'Compter les notes non significatives',
                    style: Theme.of(context).textTheme.bodyMedium
                  ),
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ],
          )
          : const Center(
            child: ErrorText(
              text: 'Vous devez avoir ajouté au moins 1 note pour voir ce type de graphique.'
            )
          );
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: 
            currentPeriod.grades.isEmpty
            ? const Center(
              child: ErrorText(text: 'Aucune note'),
            )
            : Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SColors.getBackgroundColor(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0)
                    ),
                  ),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: <Tab>[
                          for (String item in _destinations) ... {
                            Tab(
                              text: item
                            )
                          }
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                lineChartPage,
                                averageBarChartPage,
                                circularChartPage
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                )
              )
            ]
          )
        );
      }
    );
  }
}

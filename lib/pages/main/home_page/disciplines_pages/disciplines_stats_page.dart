import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

class DisciplinesStatsPage extends StatefulWidget {
  const DisciplinesStatsPage({super.key});

  @override
  State<DisciplinesStatsPage> createState() => _DisciplinesStatsPageState();
}

class _DisciplinesStatsPageState extends State<DisciplinesStatsPage> with TickerProviderStateMixin {
  final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

  bool firstLoading = true;

  final List<String> _destinations = <String>[
    'Histogramme',
    'Radar',
    'Moyenne générale',
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

  List<Color> periodAverageGradeColors = 
    <Color>[
      Colors.deepPurple,
      Colors.pink,
      Colors.red
    ];

  bool barChartSplitIntoRangePercentages = true;
  bool barChartShowCurrentAverageGrade = false;
  List<bool> barChartShowPeriodAverageGrade = <bool>[];
  
  List<bool> radarChartShowPeriods = <bool>[];
  List<Color> radarChartPeriodColors = <Color>[];

  bool lineChartIsCurved = false;
  bool lineChartShowCurrentAverage = false;
  List<bool> lineChartShowPeriodAverageGrade = <bool>[];
  bool lineChartDynamicYAxis = false;
  bool lineChartShowAverageGradeTrendLine = false;
  bool lineChartShowGradientBelowBar = false;
  bool lineChartShowLegends = false;

  bool pieChartFirstLoading = true;
  int pieChartTouchedIndex = -1;

  bool pieChartCountNonSignificativeGrades = true;

  @override
  void initState() {
    _tabController = TabController(length: _destinations.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2 && pieChartFirstLoading && !_tabController.indexIsChanging) {
        Timer.periodic(
          const Duration(milliseconds: 200), 
          (Timer timer) {
            if (pieChartTouchedIndex == 5) {
              setState(() {
                pieChartTouchedIndex = -1;
                pieChartFirstLoading = false;
              });

              timer.cancel();
              return;
            }

            setState(() {
              pieChartTouchedIndex++;
            });
          }
        );
      }
    });

    for (String pref in [
      'DSbarChartSplitIntoRangePercentages', 
      'DSbarChartShowCurrentAverage', 

      'DSlineChartIsCurved', 
      'DSlineChartShowCurrentAverage',
      'DSlineChartDynamicYAxis',
      'DSlineChartShowAverageGradeTrendLine',
      'DSlineChartShowGradientBelowBar',
      'DSlineChartShowLegends',

      'DSpieChartCountNonSignificativeGrades'
    ]) {
      if (sharedPreferences.getBool(pref) == null) {
        sharedPreferences.setBool(pref, true);
      }
    }

    setState(() {
      barChartSplitIntoRangePercentages = sharedPreferences.getBool('DSbarChartSplitIntoRangePercentages')!;
      barChartShowCurrentAverageGrade = sharedPreferences.getBool('DSbarChartShowCurrentAverage')!;

      lineChartIsCurved = sharedPreferences.getBool('DSlineChartIsCurved')!;
      lineChartShowCurrentAverage = sharedPreferences.getBool('DSlineChartShowCurrentAverage')!;
      lineChartDynamicYAxis = sharedPreferences.getBool('DSlineChartDynamicYAxis')!;
      lineChartShowAverageGradeTrendLine = sharedPreferences.getBool('DSlineChartShowAverageGradeTrendLine')!;
      lineChartShowGradientBelowBar = sharedPreferences.getBool('DSlineChartShowGradientBelowBar')!;
      lineChartShowLegends = sharedPreferences.getBool('DSlineChartShowLegends')!;

      pieChartCountNonSignificativeGrades = sharedPreferences.getBool('DSpieChartCountNonSignificativeGrades')!;
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

        final int periodIndex = user.userData.settings.periodIndex;
        final Periodicity userPeriodicity = user.userData.settings.periodicity;

        if (firstLoading) {
          barChartShowPeriodAverageGrade = List<bool>.generate(
            userPeriodicity.parts,
            (int index) => periodIndex == index
          );

          radarChartShowPeriods = List.generate(
            userPeriodicity.parts,
            (int index) => periodIndex == index
          );

          radarChartPeriodColors = <Color>[
            Colors.deepPurple,
            Theme.of(context).primaryColor,
            Colors.red
          ];

          lineChartShowPeriodAverageGrade = List<bool>.generate(
            userPeriodicity.parts, 
            (int index) => index == periodIndex
          );

          firstLoading = false;
        }

        List<HorizontalLine> barChartHorizontalLines = <HorizontalLine>[];

        if (barChartShowCurrentAverageGrade) {
          for (int k = 0; k < barChartShowPeriodAverageGrade.length; k++) {
            if (barChartShowPeriodAverageGrade[k]) {
              double selectedPeriodAverageGrade = user.userData.getAverageGrade(periodIndex: k);

              if (selectedPeriodAverageGrade == -1.0) {
                selectedPeriodAverageGrade = 0.0;
              }

              barChartHorizontalLines.add(
                HorizontalLine(
                  y: selectedPeriodAverageGrade,
                  color: periodAverageGradeColors[k],
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
            }
          }
        }

        /////////////////////////////////////
        /// Bar chart page (barChartPage) ///
        /////////////////////////////////////

        final Widget barChartPage =
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 25
                          )
                        ),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (
                              double value, 
                              TitleMeta meta
                            ) {
                              final Discipline targetedDiscipline = user.userData.disciplines.elementAt(value.toInt());
                                      
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(targetedDiscipline.abbreviation)
                              );
                            },
                            reservedSize: 30 // temp
                          )
                        )
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black.withOpacity(0.75),
                          tooltipRoundedRadius: 10,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (
                            BarChartGroupData group, 
                            int groupIndex, 
                            BarChartRodData rod, 
                            int rodIndex
                          ) {
                            final Discipline discipline = user.userData.disciplines.elementAt(groupIndex);
                            final Period period = discipline.periods.elementAt(periodIndex);
                            final double averageGrade = period.getAverageGrade;
                            final List<double> averageGradeSplittedIntoRangePercentages = discipline.getAverageGradeSplittedIntoRangePercentages(periodIndex);
                            final int gradesAmount = period.grades.length;
                            final double currentPercentage = averageGradeSplittedIntoRangePercentages.elementAt(rodIndex);

                            return BarTooltipItem(
                              SMath.formatSignificantFigures(averageGrade), // TODO: Optimizable by fetching the rod y value instead of recalculating the averageGrade (even if the difference is barely noticeable)
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                if (barChartSplitIntoRangePercentages) ... {
                                  TextSpan(
                                    text: "\n${SMath.formatSignificantFigures(currentPercentage)}% (${(gradesAmount * currentPercentage / 100).round()}/$gradesAmount)",
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: rod.color
                                    )
                                  )
                                }
                              ]
                            );
                          }
                          )
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(
                        drawVerticalLine: false
                      ),
                      barGroups: List.generate(
                        user.userData.disciplines.length, 
                        (int index) {
                          final Discipline discipline = user.userData.disciplines.elementAt(index);
                
                          double averageGrade = discipline.getAverageGrade(periodIndex);

                          if (averageGrade < 0.0) {
                            averageGrade = 0.0;
                          }

                          const double width = 12.5;

                          if (barChartSplitIntoRangePercentages) {
                            final List<double> averageGradeSplittedIntoRangePercentages = 
                              discipline.getAverageGradeSplittedIntoRangePercentages(periodIndex);
                            
                            // const double spacing = 0.25;
                            
                            double a(int index) {
                              return averageGrade * (averageGradeSplittedIntoRangePercentages[index] / 100);
                            }
                  
                            double yA = a(0);
                            if (a(0) != 0.0) {
                              // yA += spacing;
                              showLegend[0] = true;
                            }
                  
                            double yB = yA + a(1);
                            if (a(1) != 0.0) {
                              // yB += spacing;
                              showLegend[1] = true;
                            }
                  
                            double yC = yB + a(2);
                            if (a(2) != 0.0) {
                              // yC += spacing;
                              showLegend[2] = true;
                            }
                  
                            double yD = yC + a(3);
                            if (a(3) != 0.0) {
                              // yD += spacing;
                              showLegend[3] = true;
                            }
                  
                            double yE = yD + a(4);
                            if (a(4) != 0.0) {
                              // yE += spacing;
                              showLegend[4] = true;
                            }
                  
                            double yF = yE + a(5);
                            if (a(5) != 0.0) {
                              // yF += spacing;
                              showLegend[5] = true;
                            }
                  
                            return BarChartGroupData(
                              x: index,
                              groupVertically: true,
                              barRods: <BarChartRodData>[
                                BarChartRodData(
                                  fromY: 0,
                                  toY: yA,
                                  color: Grade(grade: 0).color,
                                  width: width
                                ),
                                BarChartRodData(
                                  fromY: yA,
                                  toY: yB,
                                  color: Grade(grade: 10).color,
                                  width: width
                                ),
                                BarChartRodData(
                                  fromY: yB,
                                  toY: yC,
                                  color: Grade(grade: 12).color,
                                  width: width
                                ),
                                BarChartRodData(
                                  fromY: yC,
                                  toY: yD,
                                  color: Grade(grade: 14).color,
                                  width: width
                                ),
                                BarChartRodData(
                                  fromY: yD,
                                  toY: yE,
                                  color: Grade(grade: 16).color,
                                  width: width
                                ),
                                BarChartRodData(
                                  fromY: yE,
                                  toY: yF,
                                  color: Grade(grade: 20).color,
                                  width: width
                                )
                              ],
                            );
                          }

                          return BarChartGroupData(
                            x: index,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                fromY: 0,
                                toY: averageGrade,
                                color: Theme.of(context).primaryColor,
                                width: width,
                              )
                            ]
                          );
                        }
                      ),
                      maxY: 20,
                      extraLinesData: ExtraLinesData(
                        horizontalLines: barChartHorizontalLines
                      )
                    )
                  ),
                ),
              ),

              if (barChartSplitIntoRangePercentages) ... {
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

                const SizedBox(height: 10.0)
              },

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
                                value: barChartSplitIntoRangePercentages, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      barChartSplitIntoRangePercentages = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DSbarChartSplitIntoRangePercentages', value);
                                },
                                title: Text(
                                  'Séparation en pourcentages',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),

                              const Separator(),

                              SwitchListTile.adaptive(
                                value: barChartShowCurrentAverageGrade, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      barChartShowCurrentAverageGrade = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DSbarChartShowCurrentAverageGrade', value);
                                },
                                title: Text(
                                  'Afficher la moyenne actuelle',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),
                              
                              if (barChartShowCurrentAverageGrade) ... {
                                Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Flexible>[
                                    for (int k = 0 ; k < userPeriodicity.parts; k++) ... {
                                      Flexible(
                                        child: VerticalSwitchListTile(
                                          value: barChartShowPeriodAverageGrade[k],
                                          title: "${userPeriodicity.displayName} ${k+1}",
                                          color: periodAverageGradeColors[k],
                                          showBackground: false,
                                          onChanged: (bool value) {
                                            setState(() {
                                              barChartShowPeriodAverageGrade[k] = value;
                                            });
                                          }
                                        )
                                      )
                                    }
                                  ]
                                )
                              },
                            ]
                          );
                        }
                      );
                    }
                  );
                }
              )
            ],
          );

        /////////////////////////////////////////
        /// Radar chart page (radarChartPage) ///
        /////////////////////////////////////////

        final Widget radarChartPage =
          user.userData.disciplines.length >= 3
          ? Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 4,
                    ticksTextStyle: Theme.of(context).textTheme.bodySmall,
                    titlePositionPercentageOffset: .075,
                    titleTextStyle: Theme.of(context).textTheme.titleSmall,
                    tickBorderData: BorderSide(
                      color: Colors.grey.shade400
                    ),
                    dataSets: <RadarDataSet>[
                      getConstantRadarDataSet(user.userData.disciplines.length, 0),
                      getConstantRadarDataSet(user.userData.disciplines.length, 20),
                      
                      for (int k = 0; k < userPeriodicity.parts; k++) ... {
                        if (radarChartShowPeriods[k]) ... {
                          RadarDataSet(
                            fillColor: radarChartPeriodColors[k].withOpacity(0.5),
                            borderColor: radarChartPeriodColors[k],
                            borderWidth: 4.0,
                            entryRadius: 6.0,
                            dataEntries: List<RadarEntry>.generate(
                              user.userData.disciplines.length, 
                              (int index) {
                                final Discipline discipline = user.userData.disciplines.elementAt(index);
                                double averageGrade = discipline.getAverageGrade(k);

                                if (averageGrade < 0) {
                                  averageGrade = 0;
                                }

                                return RadarEntry(
                                  value: averageGrade
                                );
                              }
                            )
                          )
                        }
                      }
                    ],
                    getTitle: (int index, double angle) {
                      final Discipline discipline = user.userData.disciplines.elementAt(index);
                      // final int periodIndex = user.userData.settings.periodIndex;
                      return RadarChartTitle(
                        text: "${discipline.abbreviation}\n${Grade(grade: discipline.getAverageGrade(periodIndex)).display}"
                      );
                    }
                  )
                ),
              ),

              const Separator(),

              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Flexible>[
                  for (int k = 0 ; k < userPeriodicity.parts; k++) ... {
                    Flexible(
                      child: VerticalSwitchListTile(
                        value: radarChartShowPeriods[k],
                        title: "${userPeriodicity.displayName} ${k+1}",
                        color: radarChartPeriodColors[k],
                        onChanged: (bool value) {
                          setState(() {
                            radarChartShowPeriods[k] = value;
                          });
                        },
                      ),
                    )
                  }
                ],
              ),
            ],
          )
          : const Center(
            child: ErrorText(
              text: 'Vous devez avoir ajouté au moins 3 matières pour regarder ce type de graphique.'
            )
          );
        
        ///////////////////////////////////////
        /// Line chart page (lineChartPage) ///
        ///////////////////////////////////////
        
        final List<double> averageGradeEvolution = user.userData.getAverageGradeEvolution(periodIndex: periodIndex);

        final List<Grade> gradesSortedByDate = user.userData.getGradesSortedByDate(periodIndex: periodIndex);

        final List<Grade> sortedGrades = 
          List<Grade>.from(gradesSortedByDate)
          ..addAll([
            for (int k = 0; k < lineChartShowPeriodAverageGrade.length; k++) ... {
              if (lineChartShowPeriodAverageGrade[k]) ... {
                Grade(
                  grade: user.userData.getAverageGrade(periodIndex: k)
                )
              }
            }
          ])
          ..sort(
            (Grade a, Grade b) => a.toPercentage.compareTo(b.toPercentage),
          );

        double minY = 0;
        double maxY = 20;

        if (lineChartDynamicYAxis) {
          minY = sortedGrades.first.toPercentage * 20 <= 1 ? 0 : sortedGrades.first.toPercentage * 20 - 1;
          maxY = sortedGrades.last.toPercentage * 20 >= 19 ? 20 : sortedGrades.last.toPercentage * 20 + 1;
        }

        List<LineChartBarData> lineChartBarData = <LineChartBarData>[
          LineChartBarData(
            isCurved: lineChartIsCurved,
            color: 
              gradesSortedByDate.length > 1 
              ? null 
              : Grade(grade: user.userData.getAverageGrade()).color,
            gradient: 
              gradesSortedByDate.length > 1 
              ? LinearGradient(
                colors: 
                  List<Color>.generate(
                    gradesSortedByDate.length, 
                    (int index) {
                      return Grade(grade: averageGradeEvolution.elementAt(index)).color;
                    }
                  )
                )
              : null,
            barWidth: 2.0,
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
              gradesSortedByDate.length, 
              (int index) {
                return FlSpot(index.toDouble(), averageGradeEvolution.elementAt(index));
              }
            )
          )
        ];

        List<HorizontalLine> lineChartHorizontalLines = <HorizontalLine>[];

        List<Legend> lineChartShownLegends = <Legend>[
          Legend(
            title: 'Évolution de la moyenne',
            color: Grade(grade: user.userData.getAverageGrade()).color,
          )
        ];

        if (lineChartShowCurrentAverage) {
          for (int k = 0; k < lineChartShowPeriodAverageGrade.length; k++) {
            if (lineChartShowPeriodAverageGrade[k]) {
              double selectedPeriodAverageGrade = user.userData.getAverageGrade(periodIndex: k);

              if (selectedPeriodAverageGrade == -1.0) {
                selectedPeriodAverageGrade = 0.0;
              }

              lineChartHorizontalLines.add(
                HorizontalLine(
                  y: selectedPeriodAverageGrade,
                  color: periodAverageGradeColors[k],
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
                  color: periodAverageGradeColors[k],
                )
              );
            }
          }
        }

        if (lineChartShowAverageGradeTrendLine) {
          final List<double> x = List<double>.generate(gradesSortedByDate.length, (int index) => index.toDouble());
          final List<double> y = List<double>.generate(gradesSortedByDate.length, (int index) => averageGradeEvolution.elementAt(index));

          List<double> trendLine = SMath.calculateTrendLine(x, y);

          lineChartBarData.add(
            LineChartBarData(
              color: const Color.fromRGBO(255, 204, 153, 1),
              barWidth: 2.0,
              dotData: const FlDotData(
                show: false
              ),
              spots: List<FlSpot>.generate(
                gradesSortedByDate.length, 
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

        final Widget averageGradeEvolutionPage =
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
                            final double averageAtX = averageGradeEvolution.elementAt(x);

                            return [
                              LineTooltipItem(
                                SMath.formatSignificantFigures(averageAtX),
                                Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: Grade(grade: averageAtX).color
                                ),
                              ),
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
                      )
                    )
                  ),
                )
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

                                  sharedPreferences.setBool('DSlineChartIsCurved', value);
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

                                  sharedPreferences.setBool('DSlineChartShowCurrentAverage', value);
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
                                          color: periodAverageGradeColors[k],
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
                                value: lineChartDynamicYAxis, 
                                onChanged: (value) {
                                  setModalState(() {
                                    setState(() {
                                      lineChartDynamicYAxis = value;
                                    });
                                  });

                                  sharedPreferences.setBool('DSlineChartDynamicYAxis', value);
                                },
                                title: Text(
                                  'Axe des ordonnées dynamique',
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

                                  sharedPreferences.setBool('DSlineChartShowAverageGradeTrendLine', value);
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

                                  sharedPreferences.setBool('DSlineChartShowGradientBelowBar', value);
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

                                  sharedPreferences.setBool('DSlineChartShowLegends', value);
                                },
                                title: Text(
                                  'Afficher la légende',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              )
                            ]
                          );
                        }
                      );
                    }
                  );
                }
              )
            ]
          );

        final List<List<Grade>> gradesSplittedIntoRange = 
          user.userData.getGradesSplittedIntoRange(
            user.userData.settings.periodIndex, 
            countNonSignificativeGrades: pieChartCountNonSignificativeGrades
          );
        
        final int touchedPartLength = pieChartTouchedIndex >= 0 ? gradesSplittedIntoRange[pieChartTouchedIndex].length : 0;
        final int gradesAmount = user.userData.getGradesAmount(periodIndex: periodIndex, countNonSignificativeGrades: pieChartCountNonSignificativeGrades);
        
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
                          final double percentage = gradesSplittedIntoRange[index].length / gradesAmount * 100;
                
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
                          "${SMath.formatSignificantFigures(touchedPartLength / gradesAmount * 100)}%",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          "$touchedPartLength/$gradesAmount",
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

                    sharedPreferences.setBool('DSpieChartCountNonSignificativeGrades', value);
                  },
                  title: Text(
                    'Compter les notes non significatives',
                    style: Theme.of(context).textTheme.bodyMedium
                  ),
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              )
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
            user.userData.disciplines.isEmpty
            ? const Center(
              child: ErrorText(text: 'Aucune matière'),
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
                                barChartPage,
                                radarChartPage,
                                averageGradeEvolutionPage,
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

RadarDataSet getConstantRadarDataSet(int length, double value) {
  return RadarDataSet(
    fillColor: Colors.transparent,
    borderColor: Colors.transparent,
    borderWidth: 0.0,
    entryRadius: 0.0,
    dataEntries: List<RadarEntry>.generate(
      length, 
      (int index) {
        return RadarEntry(value: value);
      }
    )
  );
}
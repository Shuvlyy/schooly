import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/models/grades/grade.dart';

class SCircularPercentIndicator extends StatelessWidget {
  final double percent;
  final Color color;
  final SCircularPercentIndicatorType type;
  final Widget? center;

  const SCircularPercentIndicator({
    super.key,

    required this.percent,
    this.color = Colors.red,
    this.type = SCircularPercentIndicatorType.small,
    this.center
  });

  static Widget fromGrade(
    Grade grade, 
    BuildContext context,
    { 
      SCircularPercentIndicatorType type = SCircularPercentIndicatorType.small 
    }
  ) {
    bool convertToScale20 = false;

    return StatefulBuilder(
      builder: (
        BuildContext context, 
        Function setState
      ) {
        final Grade shownGrade = 
          convertToScale20
          ? Grade(grade: grade.toPercentage * 20)
          : grade;

        double gradePercent = grade.grade / grade.maxGrade;

        TextStyle? gradeTextStyle = Theme.of(context).textTheme.titleLarge
          ?.copyWith(
            fontSize: 26.0,
            fontWeight: FontWeight.w500,
          );
        
        TextStyle? maxGradeTextStyle = Theme.of(context).textTheme.titleSmall
          ?.copyWith(
            fontSize: 14.0,
            color: SColors.getGreyscaleColor(context),
          );

        if (type == SCircularPercentIndicatorType.big) {
          gradeTextStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 52.0,
            fontWeight: FontWeight.w500
          );

          maxGradeTextStyle = Theme.of(context).textTheme.titleLarge
            ?.copyWith(
              color: Colors.grey.shade400
            );
        }

        if (type == SCircularPercentIndicatorType.veryBig) {
          gradeTextStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 72.0,
            fontWeight: FontWeight.w500
          );

          maxGradeTextStyle = Theme.of(context).textTheme.titleLarge
            ?.copyWith(
              color: Colors.grey.shade400,
              fontSize: 28.0
            );
        }

        SCircularPercentIndicator widget = SCircularPercentIndicator(
          percent: gradePercent.isNegative ? 0.001 : gradePercent,
          color: grade.color,
          type: type,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Text>[
              Text(
                grade.grade < 0 ? '--' : SMath.formatSignificantFigures(shownGrade.grade),
                style: gradeTextStyle
              ),

              Text(
                "/${SMath.formatSignificantFigures(shownGrade.maxGrade)}",
                style: maxGradeTextStyle,
              )
            ],
          ),
        );

        if (type != SCircularPercentIndicatorType.small) {
          return InkWell(
            onTap: 
              grade.maxGrade != 20.0
              ? () {
                setState(() {
                  convertToScale20 = !convertToScale20;
                });
              }
              : null,
            borderRadius: BorderRadius.circular(50.0),
            child: widget,
          );
        }

        return widget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double lineWidth =
      type == SCircularPercentIndicatorType.small ? 10.0 : 17.5;

    double radius =
      type == SCircularPercentIndicatorType.small ? 54.0 : 115.0;

    bool reverse =
      type == SCircularPercentIndicatorType.small;

    switch (type) {
      case SCircularPercentIndicatorType.big:
        lineWidth = 17.5;
        radius = 115.0;
        break;
      case SCircularPercentIndicatorType.veryBig:
        lineWidth = 20.0;
        radius = MediaQuery.of(context).size.width * 0.375;
        // radius = 150.0;
        break;
      default:
        break;
    }

    return CircularPercentIndicator(
      percent: percent,
      lineWidth: lineWidth,
      radius: radius,
      backgroundColor: Colors.transparent,
      progressColor: color,
      animation: true,
      animationDuration: 400,
      center: center,
      circularStrokeCap: CircularStrokeCap.round,
      reverse: reverse,
      curve: Curves.easeInOut,
    );
  }
}

enum SCircularPercentIndicatorType {
  small,
  big,
  veryBig
}
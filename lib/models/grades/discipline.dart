import 'package:schooly/common/smath.dart';

import 'period.dart';
import 'grade.dart';

class Discipline {
  String name;
  String abbreviation;
  double coefficient;
  List<Period> periods;

  Discipline({
    this.name = '',
    this.abbreviation = '',
    this.coefficient = 0.0,
    this.periods = const []
  });  /*: assert(abbreviation.isNotEmpty && abbreviation.length <= 5, 'Abbreviation\'s length must be between 1 and 5'),
        assert(coefficient > 0.0, 'Coefficient must be greater than 0.');*/

  static Discipline fromMap(Map<String, dynamic> map) {
    List<Period> convertedPeriods = [];

    for (var period in map['periods'] ?? []) {
      convertedPeriods.add(Period.fromMap(period, map['name']));
    }

    return Discipline(
      name: map['name'] ?? '',
      abbreviation: map['abbreviation'] ?? '',
      coefficient: map['coefficient'] ?? 0.0,
      periods: convertedPeriods
    );
  }

  Map<String, dynamic> toMap() {
    List mappedPeriods = [];

    for (var period in periods) {
      mappedPeriods.add(period.toMap());
    }

    return {
      'name': name,
      'abbreviation': abbreviation,
      'coefficient': coefficient,
      'periods': mappedPeriods
    };
  }

  bool compareTo(Discipline discipline) {
    bool result = false;

    if (discipline.name != name) result = true;
    if (discipline.abbreviation != abbreviation) result = true;
    if (discipline.coefficient != coefficient) result = true;
    if (discipline.periods != periods) result = true;

    return result;
  }

  double getAverageGrade(int periodIndex) {
    Period period;

    try {
      period = periods.elementAt(periodIndex);
    } catch (e) {
      return -1;
    }

    double averageGrade = 
      double.parse(SMath.formatSignificantFigures(period.getAverageGrade));
    
    if (averageGrade.isNaN) averageGrade = -1;

    return averageGrade;
  }

  double getAverageGradeAtTMinus(int periodIndex, int tMinus) {
    List<Grade> timeSortedGrades = <Grade>[];

    Period? period = periods.elementAtOrNull(periodIndex);
    
    if (period != null) {
      timeSortedGrades.addAll(period.grades);
    }

    if (timeSortedGrades.length < tMinus) {
      return -1.0;
    }

    timeSortedGrades.sort((Grade a, Grade b) {
      return a.creationDate!.compareTo(b.creationDate!);
    });

    timeSortedGrades.removeRange(timeSortedGrades.length - tMinus, timeSortedGrades.length);

    double grades = 0.0;
    double coefficients = 0.0;

    for (Grade grade in timeSortedGrades) {
      if (!grade.isSignificative) continue;

      grades += grade.toPercentage * 20;
      coefficients += grade.coefficient;
    }

    double averageGrade = 
      double.parse(SMath.formatSignificantFigures(grades / coefficients));
    
    // if (averageGrade.isNaN) averageGrade = -1; // not very necessary

    return averageGrade;
  }

  double getPercentIndicatorAverageGrade(int periodIndex) {
    double percent = getAverageGrade(periodIndex) / 20;

    if (percent < 0.01) {
      return 0.01;
    }

    return percent;
  }

  String getDisplayAverageGrade(int periodIndex) {
    double averageGrade = getAverageGrade(periodIndex);

    return averageGrade < 0 ? '--' : averageGrade.toString();
  }

  List<double> getAverageGradeSplittedIntoRangePercentages(int periodIndex) {
    List<double> result = List<double>.filled(6, 0.0);

    List<Grade> grades = periods.elementAt(periodIndex).grades;

    int totalGrades = grades.length;
    if (totalGrades == 0) return result;

    for (Grade grade in grades) {
      double number = grade.grade / grade.maxGrade;

      if (number < 0.5) {
        result[0]++;
        continue;
      } else if (number < 0.6) {
        result[1]++;
        continue;
      } else if (number < 0.7) {
        result[2]++;
        continue;
      } else if (number < 0.8) {
        result[3]++;
        continue;
      } else if (number < 1) {
        result[4]++;
        continue;
      } else if (number == 1) {
        result[5]++;
        continue;
      }
    }

    for (int k = 0; k < result.length; k++) {
      result[k] = (result[k] / totalGrades) * 100;
    }

    return result;
  }
}
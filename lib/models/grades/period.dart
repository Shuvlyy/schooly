import 'package:schooly/common/smath.dart';
import 'package:schooly/models/grades/grade.dart';

class Period {
  List<Grade> grades;

  Period({
    this.grades = const []
  });

  static Period fromMap(Map<String, dynamic> map, String parent) {
    List<Grade> convertedGrades = [];
    
    for (var grade in map['grades'] ?? []) {
      convertedGrades.add(Grade.fromMap(grade, parent));
    }

    return Period(grades: convertedGrades);
  }

  Map<String, dynamic> toMap() {
    List mappedGrades = [];

    for (Grade grade in grades) {
      mappedGrades.add(grade.toMap());
    }

    return {
      'grades': mappedGrades
    };
  }
  
  double get getAverageGrade {
    double grades = 0.0;
    double coefficients = 0.0;

    for (Grade grade in this.grades) {
      if (!grade.isSignificative) continue;
      
      grades += grade.toPercentage * 20 * grade.coefficient;
      coefficients += grade.coefficient;
    }

    double averageGrade = 
      double.parse(SMath.formatSignificantFigures(grades / coefficients));
    
    if (averageGrade.isNaN) averageGrade = -1;

    return averageGrade;
  }

  double getAverageGradeAtTMinus(int tMinus) {
    double grades = 0.0;
    double coefficients = 0.0;

    for (int k = 0; k < this.grades.length - tMinus; k++) {
      Grade grade = this.grades.elementAt(k);
      if (!grade.isSignificative) continue;

      grades += grade.toPercentage * 20 * grade.coefficient;
      coefficients += grade.coefficient;
    }

    double averageGrade =
      double.parse(SMath.formatSignificantFigures(grades / coefficients));
    
    if (averageGrade.isNaN) averageGrade = -1;

    return averageGrade;
  }

  double getAverageGradeAtT(int t) {
    double grades = 0.0;
    double coefficients = 0.0;

    for (int k = 0; k <= t; k++) {
      Grade grade = this.grades.elementAt(k);
      if (!grade.isSignificative) continue;

      grades += grade.toPercentage * 20 * grade.coefficient;
      coefficients += grade.coefficient;
    }

    double averageGrade =
      double.parse(SMath.formatSignificantFigures(grades / coefficients));
    
    if (averageGrade.isNaN) averageGrade = -1;

    return averageGrade;
  }

  List<List<Grade>> getGradesSplittedIntoRange({ bool countNonSignificativeGrades = true }){
    List<List<Grade>> result = List.generate(6, (_) => <Grade>[]);
    
    for (Grade grade in grades) {
      if (!grade.isSignificative && !countNonSignificativeGrades) continue;

      double number = grade.grade / grade.maxGrade;

      if (number < 0.5) {
        result[0].add(grade);
        continue;
      } 
      
      if (number < 0.6) {
        result[1].add(grade);
        continue;
      }
      
      if (number < 0.7) {
        result[2].add(grade);
        continue;
      }
      
      if (number < 0.8) {
        result[3].add(grade);
        continue;
      }
      
      if (number < 1) {
        result[4].add(grade);
        continue;
      }
      
      if (number == 1) {
        result[5].add(grade);
        continue;
      }
    }

    return result;
  }

  int getGradesAmount({ bool countNonSignificativeGrades = true }) {
    int amount = 0;

    for (Grade grade in grades) {
      if (!grade.isSignificative && !countNonSignificativeGrades) continue;
      
      amount++;
    }

    return amount;
  }
}
import 'package:schooly/common/smath.dart';
import 'package:schooly/models/grades/discipline.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/grades/period.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/settings.dart';

class SUserData {
  List<Discipline> disciplines;
  final SSettings settings;
  final SProfile profile;

  SUserData({
    this.disciplines = const [],
    required this.settings,
    required this.profile
  });

  static SUserData fromMap(Map<String, dynamic> map) {
    List<Discipline> mappedDisciplines = [];

    for (var discipline in map['disciplines'] ?? []) {
      mappedDisciplines.add(Discipline.fromMap(discipline));
    }

    return SUserData(
      disciplines: mappedDisciplines,
      settings: SSettings.fromMap(map['settings']), 
      profile: SProfile.fromMap(map['profile'])
    );
  }

  Map<String, dynamic> toMap() {
    List mappedDisciplines = [];

    for (var discipline in disciplines) {
      mappedDisciplines.add(discipline.toMap());
    }

    return {
      'disciplines': mappedDisciplines,
      'settings': settings.toMap(),
      'profile': profile.toMap()
    };
  }

  double getAverageGrade({ int? periodIndex }) {
    int pIndex = periodIndex ?? settings.periodIndex;
    double grades = 0.0;
    double coefficients = 0.0;

    for (Discipline discipline in disciplines) {
      final double disciplineAverageGrade = 
        discipline.getAverageGrade(pIndex);

      if (disciplineAverageGrade < 0.0) continue;

      grades += disciplineAverageGrade * discipline.coefficient;
      coefficients += discipline.coefficient;
    }

    double averageGrade = 
      double.parse(SMath.formatSignificantFigures(grades / coefficients));
    
    if (averageGrade.isNaN) averageGrade = -1; 

    return averageGrade;
  }

  List<double> getAverageGradeEvolution({int? periodIndex, bool countNonSignificativeGrades = true }) {
    List<double> averageGradeEvolution = <double>[];
    
    final int pIndex = periodIndex ?? settings.periodIndex;

    List<Discipline> ds = <Discipline>[];

    for (Discipline d in disciplines) {
      ds.add(
        Discipline(
          name: d.name,
          abbreviation: d.abbreviation,
          coefficient: d.coefficient,
          periods: List<Period>.generate(
            settings.periodicity.parts, 
            (int index) => Period(
              grades: []
            )
          )
        )
      );
    }
    
    final List<Grade> gradesSortedByDate = getGradesSortedByDate(periodIndex: periodIndex);

    for (int k = 0; k < gradesSortedByDate.length; k++) {
      Grade targetedGrade = gradesSortedByDate.elementAt(k);

      ds.firstWhere((Discipline d) => d.name == targetedGrade.parent).periods.elementAt(pIndex).grades.add(targetedGrade);

      double grades = 0.0;
      double coefficients = 0.0;

      for (Discipline discipline in ds) {
        double disciplineAverageGrade = discipline.getAverageGrade(pIndex);

        if (disciplineAverageGrade == -1) continue;

        grades += discipline.getAverageGrade(pIndex) * discipline.coefficient;
        coefficients += discipline.coefficient;
      }

      double averageGrade =
        double.parse(SMath.formatSignificantFigures(grades / coefficients));
      
      averageGradeEvolution.add(averageGrade);
    }

    return averageGradeEvolution;
  }

  List<List<Grade>> getGradesSplittedIntoRange(int periodIndex, { bool countNonSignificativeGrades = true }){
    List<List<Grade>> result = List.generate(6, (_) => <Grade>[]);
    
    for (Discipline discipline in disciplines) {
      for (Grade grade in discipline.periods.elementAt(periodIndex).grades) {
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
    }

    return result;
  }

  int getGradesAmount({ int? periodIndex,  bool countNonSignificativeGrades = true }) {
    int pIndex = periodIndex ?? settings.periodIndex;

    int amount = 0;

    for (Discipline discipline in disciplines) {
      for (Grade grade in discipline.periods.elementAt(pIndex).grades) {
        if (!grade.isSignificative && !countNonSignificativeGrades) continue;
        
        amount++;
      }
    }

    return amount;
  }

  List<Grade> getGradesSortedByDate({ int? periodIndex, bool countNonSignificativeGrades = true }) {
    final int pIndex = periodIndex ?? settings.periodIndex;

    List<Grade> timeSortedGrades = <Grade>[];

    for (Discipline discipline in disciplines) {
      Period? period = discipline.periods.elementAtOrNull(pIndex);
      
      if (period != null) {
        timeSortedGrades.addAll(
          period.grades..where(
            (Grade g) => g.isSignificative || (!g.isSignificative && countNonSignificativeGrades)
          )
        );
      }
    }

    timeSortedGrades.sort((Grade a, Grade b) {
      return a.creationDate!.compareTo(b.creationDate!);
    });

    return timeSortedGrades;
  }
}
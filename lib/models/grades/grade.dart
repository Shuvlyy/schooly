import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schooly/common/smath.dart';

class Grade {
  double grade;
  double maxGrade;
  double coefficient;
  DateTime? creationDate;
  GradeType type;
  String subject;
  bool isSignificative;
  String parent;

  Grade({
    this.grade = 0.0,
    this.maxGrade = 20.0,
    this.coefficient = 1.0,
    this.creationDate,
    this.type = GradeType.other,
    this.subject = '',
    this.isSignificative = true,
    this.parent = ''
  }); /*  : assert(grade >= 0.0, 'Grade must be greater or equal to 0.'), 
        assert(grade < maxGrade, 'Grade must be inferior than maximum grade.'), 
        assert(coefficient > 0.0, 'Coefficient must be greater than 0.');*/

  static Grade fromMap(Map<String, dynamic> map, String parent) {
    return Grade(
      grade: map['grade'] ?? 0,
      maxGrade: map['maxGrade'] ?? 0,
      coefficient: map['coefficient'] ?? 0,
      creationDate: ((map['creationDate'] as Timestamp?) ?? Timestamp.now()).toDate(),
      type: GradeType.values.firstWhere((element) => element.name == (map['type'] ?? 'supervisedHomework')),
      subject: map['subject'] ?? '',
      isSignificative: map['isSignificative'] ?? false,
      parent: parent
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'maxGrade': maxGrade,
      'coefficient': coefficient,
      'creationDate': creationDate,
      'type': type.name,
      'subject': subject,
      'isSignificative': isSignificative
    };
  }

  double get toPercentage {
    double percent = grade / maxGrade;

    if (percent < 0.01) {
      return 0.01;
    }

    return percent;
  }

  String get display {
    if (grade == -1) {
      return '--';
    }

    return "${!isSignificative ? 'N.S • ' : ''}${SMath.formatSignificantFigures(grade)} / ${SMath.formatSignificantFigures(maxGrade)}";
  }

  Color get color {
    double note = grade / maxGrade;

    if (note < 0) return Colors.grey.shade300;
    if (note < 0.5) return Colors.red;
    if (note < 0.6) return Colors.orange;
    if (note < 0.7) return Colors.yellow;
    if (note < 0.8) return Colors.lightGreen;
    if (note < 1) return Colors.green;
    if (note == 1) return Colors.green.shade700;

    return Colors.grey.shade300;
  }
}

enum GradeType {
  supervisedHomework,
  homework,
  oral,
  exam,
  practicalWork,
  other
}

extension GradeTypeExtension on GradeType {
  String get detailedDisplayName {
    switch(this) {
      case GradeType.supervisedHomework:
        return 'Devoir Surveillé (DS)';
      case GradeType.homework:
        return 'Devoir Maison (DM)';
      case GradeType.oral:
        return 'Oral';
      case GradeType.exam:
        return 'Examen';
      case GradeType.practicalWork:
        return 'Travail Pratique (TP)';
      case GradeType.other:
        return 'Autre';
      default:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case GradeType.supervisedHomework:
        return 'DS';
      case GradeType.homework:
        return 'DM';
      case GradeType.oral:
        return 'Oral';
      case GradeType.exam:
        return 'Exam';
      case GradeType.practicalWork:
        return 'TP';
      case GradeType.other:
        return 'Autre';
      default:
        return '';
    }
  }
}
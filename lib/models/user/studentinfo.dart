class StudentInformations {
  String gradeClass;
  String establishment;

  StudentInformations({
    this.gradeClass = '',
    this.establishment = ''
  });

  static StudentInformations fromMap(Map<String, dynamic> map) {
    return StudentInformations(
      gradeClass: map['gradeClass'] ?? '',
      establishment: map['establishment'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gradeClass': gradeClass,
      'establishment': establishment
    };
  }

  String get gradeClassDisplay {
    if (gradeClass == '') {
      return '--';
    }
    
    return gradeClass;
  }

  String get establishmentDisplay {
    if (establishment == '') {
      return '--';
    }

    return establishment;
  }
}
class Regexes {
  static RegExp get email =>
    RegExp(
      r'''(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])''',
      caseSensitive: false
    );
  
  static RegExp get username => RegExp(r'''^[a-z0-9_.-]*$''');
  
  ////// Passwords //////

  static RegExp get password =>
    RegExp(r'''^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$''');
  
  static RegExp get eightCharactersMinimum =>
    RegExp(r'''^.{8,}$''');
  
  static RegExp get oneCapitalizedLetter =>
    RegExp(r'''^(?=.*[A-Z]).+$''');
  
  static RegExp get oneNonCapitalizedLetter =>
    RegExp(r'''^(?=.*[a-z]).+$''');
  
  static RegExp get oneSpecialCharacter =>
    RegExp(r'''^(?=.*[\W_]).+$''');

  ///////////////////////
  
  static RegExp get twoDecimalsDouble => // Double with a maximum of 2 decimals
    RegExp(r'''^\d+\.?\d{0,2}''');
}
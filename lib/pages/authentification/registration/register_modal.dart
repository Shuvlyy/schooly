import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/privacysettings.dart';

class RegisterModal {

  String displayName = '';
  String username = '';
  String email = '';
  String password = '';
  Periodicity periodicity = Periodicity.semester;
  PrivacySettings privacySettings = PrivacySettings();
  int currentPage = 0;
  int totalPages = 5;

  String get getDisplayName => displayName;
  set setDisplayName(String value) => displayName = value;

  String get getUsername => username;
  set setUsername(String value) => username = value;

  String get getEmail => email;
  set setEmail(String value) => email = value;

  String get getPassword => password;
  set setPassword(String value) => password = value;

  Periodicity get getPeriodicity => periodicity;
  set setPeriodicity(Periodicity value) => periodicity = value;

  PrivacySettings? get getPrivacySettings => privacySettings;
  set setPrivacySettings(PrivacySettings value) => privacySettings = value;

  int get getCurrentPage => currentPage;
  set setCurrentPage(int value) => currentPage = value;
  
}
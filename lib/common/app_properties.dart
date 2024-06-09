import 'package:schooly/models/user/periodicity.dart';

class AppProperties {
  static String get title => 'Schooly';
  static String get version => '0.3.10a';
  static DateTime get versionReleaseDate => DateTime.utc(2023, 8, 3, 20, 13, 56);

  static Duration get databaseRequestMaxDuration => const Duration(seconds: 5);

  static String get defaultUsername => 'defaultUser';
  static DateTime get defaultJoinDate => DateTime.utc(2006, 7, 3, 14, 17, 0);
  static Periodicity get defaultPeriodicity => Periodicity.semester;

  static int maxDisplayNameLength = 20;
  static int maxUsernameLength = 16;
  static int maxAmountOfDisciplines = 15; // TODO: Modify this?
  static int maxAmountOfGradesPerDisciplinePerPeriod = 15; // TODO: This too?
  static int maxDisciplineNameLength = 25;
  static int maxDisciplineAbbreviationLength = 5;
}
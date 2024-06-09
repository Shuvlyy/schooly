import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseConsts {
  final String lastAppVersion;
  final DateTime lastAppVersionReleaseDate;
  final bool areRegistrationsAuthorized;
  final Uri lastVersionApkLink;
  final String acceptedVersions;

  DatabaseConsts({
    required this.lastAppVersion,
    required this.lastAppVersionReleaseDate,
    required this.areRegistrationsAuthorized,
    required this.lastVersionApkLink,
    required this.acceptedVersions
  });

  static DatabaseConsts fromMap(Map<String, dynamic> map) {
    return DatabaseConsts(
      lastAppVersion: map['appVersion'],
      lastAppVersionReleaseDate: (map['appVersionReleaseDate'] as Timestamp).toDate(),
      areRegistrationsAuthorized: map['areRegistrationsAuthorized'],
      lastVersionApkLink: Uri.parse(map['lastAppApkLink']),
      acceptedVersions: map['acceptedVersions']
    );
  }
}
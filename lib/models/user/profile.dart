import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/models/user/sbadge.dart';
import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/studentinfo.dart';

class SProfile {
  String username;
  String displayName;

  DateTime? joinedAt;

  String appVersion;

  LocationInformations locationInformations;
  StudentInformations studentInformations;

  List<SBadge> badges;

  SProfile({
    this.username = '', 
    this.displayName = '',
    this.joinedAt,
    this.appVersion = '',
    required this.locationInformations,
    required this.studentInformations,
    this.badges = const []
  });

  static SProfile fromMap(Map<String, dynamic> map) {
    List<SBadge> convertedBadges = [];

    for (var badge in map['badges'] ?? []) {
      convertedBadges.add(SBadge.fromName(badge));
    }

    return SProfile(
      username: map['username'] ?? AppProperties.defaultUsername,
      displayName: map['displayName'] ?? map['nickname'] ?? AppProperties.defaultUsername,

      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? AppProperties.defaultJoinDate,

      appVersion: map['appVersion'] ?? AppProperties.version,

      locationInformations: LocationInformations.fromMap(map['locationInformations'] ?? {}),
      studentInformations: StudentInformations.fromMap(map['studentInformations'] ?? {}),

      badges: convertedBadges
    );
  }

  Map<String, dynamic> toMap() {
    badges.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return {
      'username': username,
      'displayName': displayName,

      'joinedAt': joinedAt,

      'appVersion': AppProperties.version,

      'locationInformations': locationInformations.toMap(),
      'studentInformations': studentInformations.toMap(),

      'badges': 
        (List<SBadge>.from(badges)
        ..sort(
          (SBadge a, SBadge b) => b.zIndex.compareTo(a.zIndex)
        ))
        .map((SBadge badge) => badge.name)
    };
  }

  void replaceWith(SProfile profile) {
    username = profile.username;
    displayName = profile.displayName;

    joinedAt = profile.joinedAt;

    locationInformations = profile.locationInformations;
    studentInformations = profile.studentInformations;

    badges = profile.badges;
  }

  String get formattedJoinedAt {
    return DateFormat('dd/MM/yyyy').format(joinedAt!);
  }
}
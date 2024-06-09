import 'package:flutter/material.dart';

class PrivacySettings {
  SPrivacy
    profile,
    grades,
    location,
    friendList;
  
  bool acceptFriendRequests;
  
  PrivacySettings({
    this.profile = const SPrivacy(type: SPrivacyType.profile),
    this.grades = const SPrivacy(type: SPrivacyType.grades),
    this.location = const SPrivacy(type: SPrivacyType.location),
    this.friendList = const SPrivacy(type: SPrivacyType.friendList),
    this.acceptFriendRequests = false
  });

  static PrivacySettings fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      profile: SPrivacy.fromMap(map['profile'] ?? {}, SPrivacyType.profile),
      grades: SPrivacy.fromMap(map['grades'] ?? {}, SPrivacyType.grades),
      location: SPrivacy.fromMap(map['location'] ?? {}, SPrivacyType.location),
      friendList: SPrivacy.fromMap(map['friendList'] ?? {}, SPrivacyType.friendList),
      acceptFriendRequests: map['acceptFriendRequests'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile.toMap(),
      'grades': grades.toMap(),
      'location': location.toMap(),
      'friendList': friendList.toMap(),
      'acceptFriendRequests': acceptFriendRequests,
    };
  }
}

class SPrivacy {
  final SPrivacyType type;
  final SPrivacySetting privacy;
  final SPrivacyLevel? level;

  const SPrivacy({
    required this.type,
    this.privacy = SPrivacySetting.public,
    this.level
  });

  static SPrivacy fromMap(Map<String, dynamic> map, SPrivacyType type) {
    return SPrivacy(
      type: type,
      privacy: SPrivacySetting.values.firstWhere((element) => element.name == (map['privacy'] ?? 'private')),
      level: 
        map['level'] != null
        ? SPrivacyLevel.values.firstWhere((element) => element.name == map['level'])
        : null
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      'privacy': privacy.name
    };

    if (level != null) {
      result['level'] = level!.name;
    }
    
    return {
      'privacy': privacy.name,
      if (level != null) ... {
        'level': level?.name
      }
    };
  }
}

extension SPrivacyExtension on SPrivacy {
  String get displayName {
    switch (type) {
      case SPrivacyType.profile:
        return 'Profil';
      case SPrivacyType.grades:
        return 'Notes';
      case SPrivacyType.location:
        return 'Localisation';
      case SPrivacyType.friendList:
        return "Liste d'ami";
      default:
        return '';
    }
  }

  String get description {
    switch (type) {
      case SPrivacyType.profile:
        return "Choisissez qui peut voir votre profil utilisateur.\nLes informations basiques tels que le pseudo, nom d'utilisateur et photo de profil resteront publiques.";
      case SPrivacyType.grades:
        return "Choisissez qui peut voir vos notes et ce qu'ils peuvent voir.";
      case SPrivacyType.location:
        return "Choisissez qui peut voir votre localisation et à quel degré de précision.";
      case SPrivacyType.friendList:
        return "Choisissez qui peut voir votre liste d'amis.";
      default:
        return '';
    }
  }

  IconData get icon {
    switch (type) {
      case SPrivacyType.profile:
        return Icons.person_rounded;
      case SPrivacyType.grades:
        return Icons.drag_handle_rounded;
      case SPrivacyType.location:
        return Icons.location_on_rounded;
      case SPrivacyType.friendList:
        return Icons.person_rounded;

      default:
        return Icons.person_rounded;
    }
  }

  Color get color {
    switch (type) {
      case SPrivacyType.profile:
        return const Color.fromRGBO(109, 31, 118, 1);
      case SPrivacyType.grades:
        return const Color.fromRGBO(225, 152, 76, 1);
      case SPrivacyType.location:
        return const Color.fromRGBO(247, 102, 94, 1);
      case SPrivacyType.friendList:
        return const Color.fromRGBO(188, 226, 158, 1);

      default:
        return Colors.black;
    }
  }
}

enum SPrivacyType {
  profile,
  grades,
  location,
  friendList
}

enum SPrivacySetting {
  public,
  friendsOnly,
  private
}

extension SPrivacySettingExtension on SPrivacySetting {
  String get displayName {
    switch (this) {
      case SPrivacySetting.public:
        return 'Tout le monde';
      case SPrivacySetting.friendsOnly:
        return 'Amis uniquement';
      case SPrivacySetting.private:
        return 'Personne';

      default:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case SPrivacySetting.public:
        return Icons.language_rounded;
      case SPrivacySetting.friendsOnly:
        return Icons.person_rounded;
      case SPrivacySetting.private:
        return Icons.person_off_rounded;

      default:
        return Icons.person_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SPrivacySetting.public:
        return const Color.fromRGBO(162, 193, 224, 1);
      case SPrivacySetting.friendsOnly:
        return const Color.fromRGBO(188, 226, 158, 1);
      case SPrivacySetting.private:
        return const Color.fromRGBO(247, 102, 94, 1);

      default:
        return Colors.black;
    }
  }
}

enum SPrivacyLevel {
  gradeEverything,
  gradeAveragesOnly,
  gradeGlobalAverageOnly,
  gradeNothing,

  locationEverything,
  locationOnlyCity,
  locationOnlyCountry,
  locationNothing
}

extension SPrivacyLevelExtension on SPrivacyLevel {
  String get displayName {
    switch (this) {
      case SPrivacyLevel.gradeEverything:
        return 'Tout';
      case SPrivacyLevel.gradeAveragesOnly:
        return 'Moyennes uniquement';
      case SPrivacyLevel.gradeGlobalAverageOnly:
        return 'Moyenne générale uniquement';
      case SPrivacyLevel.gradeNothing:
        return 'Rien';

      case SPrivacyLevel.locationEverything:
        return 'Tout';
      case SPrivacyLevel.locationOnlyCity:
        return 'Ville uniquement';
      case SPrivacyLevel.locationOnlyCountry:
        return 'Pays uniquement';
      case SPrivacyLevel.locationNothing:
        return 'Rien';

      default:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case SPrivacyLevel.gradeEverything:
        return Icons.list_alt_rounded;
      case SPrivacyLevel.gradeAveragesOnly:
        return Icons.format_list_numbered_rounded;
      case SPrivacyLevel.gradeGlobalAverageOnly:
        return Icons.tag_rounded;
      case SPrivacyLevel.gradeNothing:
        return Icons.block_rounded;

      case SPrivacyLevel.locationEverything:
        return Icons.my_location_rounded;
      case SPrivacyLevel.locationOnlyCity:
        return Icons.location_on_rounded;
      case SPrivacyLevel.locationOnlyCountry:
        return Icons.map_rounded;
      case SPrivacyLevel.locationNothing:
        return Icons.location_off_rounded;

      default:
        return Icons.question_mark_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SPrivacyLevel.gradeEverything:
        return const Color.fromRGBO(188, 226, 158, 1);
      case SPrivacyLevel.gradeAveragesOnly:
        return const Color.fromRGBO(225, 152, 76, 1);
      case SPrivacyLevel.gradeGlobalAverageOnly:
        return const Color.fromRGBO(225, 152, 76, 1);
      case SPrivacyLevel.gradeNothing:
        return const Color.fromRGBO(247, 102, 94, 1);

      case SPrivacyLevel.locationEverything:
        return const Color.fromRGBO(188, 226, 158, 1);
      case SPrivacyLevel.locationOnlyCity:
        return const Color.fromRGBO(225, 152, 76, 1);
      case SPrivacyLevel.locationOnlyCountry:
        return const Color.fromRGBO(225, 152, 76, 1);
      case SPrivacyLevel.locationNothing:
        return const Color.fromRGBO(247, 102, 94, 1);

      default:
        return Colors.black;
    }
  }
}
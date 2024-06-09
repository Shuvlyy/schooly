import 'package:flutter/material.dart';
import 'package:schooly/widgets/tiles/dropdown_tile.dart';

enum Periodicity {
  semester,
  trimester
}

extension PeriodicityExtension on Periodicity {
  String get displayName {
    switch (this) {
      case Periodicity.semester:
        return 'Semestre';
      case Periodicity.trimester:
        return 'Trimestre';
      default:
        return '';
    }
  }

  String get displayPeriodicityName {
    switch (this) {
      case Periodicity.semester:
        return 'Semestriel';
      case Periodicity.trimester:
        return 'Trimestriel';
      default:
        return '';
    }
  }

  String get description {
    switch (this) {
      case Periodicity.semester:
        return 'Année divisée en 2';
      case Periodicity.trimester:
        return 'Année divisée en 3';
      default:
        return '';
    }
  }

  int get parts {
    switch (this) {
      case Periodicity.semester:
        return 2;
      case Periodicity.trimester:
        return 3;
      default:
        return 0;
    }
  }

  DropdownTileOption get dropdownTileOption {
    IconData icon = Icons.access_time_filled_rounded;
    Color color = const Color.fromRGBO(119, 221, 118, 1);

    if (this == Periodicity.trimester) {
      icon = Icons.access_time_outlined;
      color = const Color.fromRGBO(143, 184, 202, 1);
    }

    return DropdownTileOption(
      name: name, 
      displayName: displayName, 
      subtitle: "Année divisée en $parts",
      icon: icon, 
      color: color
    );
  }
}
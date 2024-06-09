import 'package:get_it/get_it.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/privacysettings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSettings {
  Periodicity periodicity;
  int periodIndex;

  PrivacySettings? privacySettings;

  SSettings({
    this.periodicity = Periodicity.semester,
    this.periodIndex = 0,
    this.privacySettings
  });

  static SSettings fromMap(Map<String, dynamic> map) {
    return SSettings(
      periodicity: Periodicity.values.firstWhere((element) => element.name == (map['periodicity'] ?? AppProperties.defaultPeriodicity.name)),
      periodIndex: GetIt.I<SharedPreferences>().getInt('periodIndex') ?? 0,
      privacySettings: PrivacySettings.fromMap(map['privacySettings'] ?? {})
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'periodicity': periodicity.name,
      'privacySettings': privacySettings?.toMap()
    };
  }
}
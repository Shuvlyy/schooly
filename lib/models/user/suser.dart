import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/settings.dart';
import 'package:schooly/models/user/studentinfo.dart';
import 'package:schooly/models/user/suserdata.dart';

class SUser {
  final String uid;
  final SUserData userData;

  const SUser({
    this.uid = '',
    required this.userData
  });

  static SUser empty({ String uid = '' }) {
    return SUser(
      uid: uid,
      userData: SUserData(
        disciplines: [],
        settings: SSettings(),
        profile: SProfile(
          locationInformations: LocationInformations(),
          studentInformations: StudentInformations()
        )
      )
    );
  }

  static SUser fromMap(
    Map<String, dynamic> map, 
    { String uid = '' }
  ) => SUser(
    uid: uid,
    userData: SUserData.fromMap(map)
  );

  Map<String, dynamic> toMap() {
    return userData.toMap();
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/network.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Duration maxTimeout = AppProperties.databaseRequestMaxDuration;

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid
  });

  static final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
  static final CollectionReference utilsCollection = FirebaseFirestore.instance.collection('Utils');

  SUser _sUserFromSnapshot(DocumentSnapshot snapshot) {
    // print(snapshot.data());
    // print("detected something");

    SUser user = SUser.fromMap(
      uid: uid,
      snapshot.data() as Map<String, dynamic>
    );

    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) => user.userData.settings.periodIndex = prefs.getInt('periodIndex') ?? 0
    );

    return user;
  }

  Future<Map<String, dynamic>> constsFromDatabase() async =>
    (await utilsCollection.doc('Consts').get()).data() as Map<String, dynamic>;

  Stream<SUser> get user {
    return userCollection.doc(uid).snapshots().map(_sUserFromSnapshot);
  }

  Future<SStatus> saveUser(SUser user) async {
    if (!await Network.isInternetAvailable) {
      return SStatus.fromModel(SStatusModel.NET_ERR_NO_CONNECTION);
    }

    SStatus status = SStatus.fromModel(SStatusModel.PENDING);

    try {
      await userCollection.doc(uid).set(user.userData.toMap())
        .then((_) => status = SStatus.fromModel(SStatusModel.OK))
        .timeout(maxTimeout);
    } on TimeoutException {
      status = SStatus.fromModel(SStatusModel.DB_ERR_NO_RESPONSE);
    } catch (e) {
      status = SStatus.fromModel(SStatusModel.UNKNOWN);
    }

    return status;
  }

  static Future<dynamic> doesUsernameExists(String username) async {
    if (!await Network.isInternetAvailable) {
      return SStatus.fromModel(SStatusModel.NET_ERR_NO_CONNECTION);
    }

    try {
      final QuerySnapshot<Object?> query =
        await FirebaseFirestore.instance
          .collection('Users')
          .where(
            'profile.username', 
            isEqualTo: username
          )
          .get()
          .timeout(maxTimeout);
          
      return query.size > 0 ? true : false;
    } on TimeoutException {
      return SStatus.fromModel(SStatusModel.DB_ERR_NO_RESPONSE);
    } catch (e) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  static Future<dynamic> getUserByUid(String uid) async {
    if (!await Network.isInternetAvailable) {
      return SStatus.fromModel(SStatusModel.NET_ERR_NO_CONNECTION);
    }

    try {
      DocumentSnapshot<Object?> snapshot = 
        await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get()
          .timeout(maxTimeout);

      return SUser.fromMap(
        uid: uid,
        snapshot.data() as Map<String, dynamic>
      );
    } on TimeoutException {
      return SStatus.fromModel(SStatusModel.DB_ERR_NO_RESPONSE);
    } catch (e) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  static Future<dynamic> getUserSnapshotByUid(String uid) async {
    if (!await Network.isInternetAvailable) {
      return SStatus.fromModel(SStatusModel.NET_ERR_NO_CONNECTION);
    }

    try {
      DocumentSnapshot<Object?> snapshot = 
        await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get()
          .timeout(maxTimeout);

      return snapshot;
    } on TimeoutException {
      return SStatus.fromModel(SStatusModel.DB_ERR_NO_RESPONSE);
    } catch (e) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }
}
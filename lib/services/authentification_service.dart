import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/settings.dart';
import 'package:schooly/models/user/studentinfo.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/models/user/suserdata.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthentificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SUser? _userFromFirebaseUser(User? user) {
    SUser? result;

    if (user == null) {
      result = null;
    } else {
      result = SUser.empty(uid: user.uid);
    }

    return result;
  }

  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (exception) {
      switch (exception.code) {
        case "user-not-found":
          return SStatus.fromModel(SStatusModel.AUTH_ERR_WRONG_CREDENTIALS_EMAIL);
        case "wrong-password":
          return SStatus.fromModel(SStatusModel.AUTH_ERR_WRONG_CREDENTIALS_PASSWORD);
      }
    } catch (e) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  Future<dynamic> registerWithEmailAndPassword(RegisterModal registerModal) async {
    try {
      UserCredential result =
        await _auth.createUserWithEmailAndPassword(
          email: registerModal.email, 
          password: registerModal.password
        );
      
      User user = result.user!;
      
      SUser sUser = SUser(
        uid: user.uid,
        userData: SUserData(
          settings: SSettings(
            periodicity: registerModal.periodicity,
            privacySettings: registerModal.privacySettings
          ), 
          profile: SProfile(
            username: registerModal.username,
            displayName: registerModal.displayName,
            joinedAt: DateTime.now(),
            locationInformations: LocationInformations(),
            studentInformations: StudentInformations(),
            badges: []
          )
        )
      );

      await DatabaseService(uid: user.uid).saveUser(sUser);
      
      return sUser;
      // return _userFromFirebaseUser(user);
    } catch(exception) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  Future<SStatus> signOut() async {
    try {
      await _auth.signOut();
      GetIt.I<SharedPreferences>().setInt('periodIndex', 0);
      GetIt.I<SharedPreferences>().setInt('theme', 0);
      return SStatus.fromModel(SStatusModel.OK);
    } catch(exception) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  Stream<SUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  String get uid {
    return _auth.currentUser != null ? _auth.currentUser!.uid : '';
  }

  String get email {
    return _auth.currentUser != null ? _auth.currentUser!.email! : '';
  }

  bool get emailVerified {
    return _auth.currentUser != null ? _auth.currentUser!.emailVerified : false;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }
}
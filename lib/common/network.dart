import 'package:connectivity/connectivity.dart';

class Network {
  static Future<bool> get isInternetAvailable async =>
    await Connectivity().checkConnectivity() != ConnectivityResult.none;
}
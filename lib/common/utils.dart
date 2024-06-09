import 'dart:io' show Platform, exit;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/widgets/popups/error_popup.dart';

class Utils {
  static void unfocus(BuildContext context) {
    try {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } catch (exception) {
      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return ErrorPopup(error: SStatus.fromModel(SStatusModel.UNKNOWN));
        }
      );
    }
  }

  static bool isDarkMode(BuildContext context)
    => Theme.of(context).brightness == Brightness.dark;
  
  static void exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }
}
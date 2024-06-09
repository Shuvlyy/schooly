import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:schooly/widgets/tiles/dropdown_tile.dart';

///***************************************************///
/// theme = 0 : Automatic mode (follows system theme) ///
/// theme = 1 : Light mode                            ///
/// theme = 2 : Dark mode                             ///
///***************************************************///

class STheme {
  final int theme;
  final MaterialColor color = MaterialColor(
    const Color.fromRGBO(183, 98, 193, 1).value,
    const <int, Color> {
      50: Color.fromRGBO(183, 98, 193, 0.1),
      100: Color.fromRGBO(183, 98, 193, 0.2),
      200: Color.fromRGBO(183, 98, 193, 0.3),
      300: Color.fromRGBO(183, 98, 193, 0.4),
      400: Color.fromRGBO(183, 98, 193, 0.5),
      500: Color.fromRGBO(183, 98, 193, 0.6),
      600: Color.fromRGBO(183, 98, 193, 0.7),
      700: Color.fromRGBO(183, 98, 193, 0.8),
      800: Color.fromRGBO(183, 98, 193, 0.9),
      900: Color.fromRGBO(183, 98, 193, 1),
    }
  );

  STheme({ this.theme = 0 });

  ThemeData getThemeData() {
    Brightness brightness = getBrightnessByMode(theme);

    return ThemeData(
      fontFamily: 'Kanit',
      brightness: brightness,
      useMaterial3: true,

      primaryColor: color,
      primarySwatch: color,
      dividerColor: const Color.fromRGBO(123, 56, 131, 1),
      // toggleableActiveColor: color,
      
      // accentColor: color,

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0.0,

        toolbarHeight: 82.0,
        scrolledUnderElevation: 0.0
      ),

      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: color.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            color: color,
            fontSize: 12.0,
            fontWeight: FontWeight.w500
          )
        ),
        
        iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: color);
          }
          
          return IconThemeData(color: brightness == Brightness.light ? Colors.black : Colors.white);
        }),
      )

      // textTheme: TextTheme(
      //   titleSmall: TextStyle(
      //     fontSize: 16.0,
      //     color: 
      //       brightness == Brightness.light 
      //       ? const Color.fromRGBO(206, 206, 206, 1)
      //       : const Color.fromRGBO(128, 128, 128, 1)
      //   ),

      //   bodyMedium: const TextStyle(
      //     // fontSize: 16
      //   ),

      //   bodyLarge: const TextStyle(
      //     fontSize: 16.0,
      //     fontWeight: FontWeight.normal
      //   ),
      // ),
    );
  }

  Brightness getBrightnessByMode(int mode) {
    switch (mode) {
      case 1:
        return Brightness.light;
      case 2:
        return Brightness.dark;
      default:
        return SchedulerBinding.instance.window.platformBrightness;
    }
  }

  static DropdownTileOption getDropdownTileOption(int themeMode) {
    String name = 'system';
    String displayName = 'Automatique';
    IconData icon = Icons.auto_awesome_rounded;
    Color color = const Color.fromRGBO(119, 221, 118, 1);

    switch (themeMode) {
      case 1:
        name = 'light';
        displayName = 'Clair';
        icon = Icons.light_mode_rounded;
        color = const Color.fromRGBO(255, 200, 130, 1);
        break;
      case 2:
        name = 'dark';
        displayName = 'Sombre';
        icon = Icons.dark_mode_rounded;
        color = const Color.fromRGBO(64, 64, 64, 1);
        break;
      default:
        break;
    }

    return DropdownTileOption(
      name: name, 
      displayName: displayName, 
      subtitle: themeMode == 0 ? 'S\'adapte au thème du téléphone' : null,
      icon: icon, 
      color: color,
    );
  }
}
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/main.dart';
import 'package:schooly/models/stheme.dart';
import 'package:schooly/models/user/periodicity.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/dropdown_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

  int themeMode = -1;

  @override
  void initState() {
    setState(() {
      themeMode = sharedPreferences.getInt('theme') ?? 0;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    final Periodicity userPeriodicity = user.userData.settings.periodicity;

    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: SAppBar(
        leading: AppBarLeadingButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () {
            context.pop();
          }
        ),
        title: const SLogo()
      ),
      body: DefaultPageLayout(
        autoSpacing: false,
        body: <Widget>[
          Text(
            'Paramètres > Application',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          DropdownTile.fromDropdownTileOptions(
            context: context, 
            title: 'Périodicité', 
            description: 'Choisissez votre type de périodicité', 
            icon: Icons.access_time_filled_rounded, 
            color: const Color.fromRGBO(216, 191, 216, 1), 
            baseValue: userPeriodicity.dropdownTileOption, 
            values: Periodicity.values.map(
              (Periodicity periodicity) => periodicity.dropdownTileOption
            ).toList(),
            onConfirm: (String value) async {
              Periodicity oldValue = user.userData.settings.periodicity;

              setState(() {
                user.userData.settings.periodicity = 
                  Periodicity.values.firstWhere(
                    (Periodicity periodicity) => periodicity.name == value
                  );
                  
                GetIt.I.registerSingleton<SUser>(user);
              });

              SStatus result = await DatabaseService(uid: user.uid).saveUser(user);
            
              if (result.failed) {
                setState(() {
                  user.userData.settings.periodicity = oldValue;
                  GetIt.I.registerSingleton<SUser>(user);
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  },
                );
              }
            },
          ),

          themeMode != -1
          ? DropdownTile.fromDropdownTileOptions(
            context: context, 
            title: 'Thème', 
            description: 'Choisissez votre thème', 
            icon: Icons.color_lens_rounded, 
            color: const Color.fromRGBO(128, 203, 196, 1), 
            baseValue: STheme.getDropdownTileOption(themeMode),
            values: [1, 2, 0].map(
              (int index) => STheme.getDropdownTileOption(index)
            ).toList(), 
            onConfirm: (String value) async {
              int oldValue = themeMode;

              setState(() {
                themeMode = ThemeMode.values.firstWhere((ThemeMode themeMode) => themeMode.name == value).index;
              });

              SStatus result = App.of(context)!.updateTheme(themeMode);

              if (result.failed) {
                setState(() {
                  themeMode = oldValue;
                });

                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return ErrorPopup(error: result);
                  }
                );
              } else {
                sharedPreferences.setInt('theme', themeMode);
              }
            },
          )
          : DropdownTile.shimmerLoading(context)
        ]
      )
    );
  }
}
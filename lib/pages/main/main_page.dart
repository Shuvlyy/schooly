import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/database_consts.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/pages/main/class_page/class_page.dart';
import 'package:schooly/pages/main/friends_page/friends_page.dart';
import 'package:schooly/pages/main/home_page/home_page.dart';
import 'package:schooly/pages/main/profile_page/profile_page.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/loading_indicator.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _pages = <Widget>[
    const HomePage(), 
    const FriendsPage(), 
    const ClassPage(), 
    const ProfilePage()
  ];

  int _selectedDestination = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  final DatabaseConsts databaseConsts = GetIt.I<DatabaseConsts>();

  @override
  Widget build(BuildContext context) {
    final AuthentificationService auth = AuthentificationService();

    SUser user = SUser.empty(uid: auth.uid);

    final Stream<SUser> userStream = DatabaseService(uid: user.uid).user;

    return Scaffold(
      body: StreamBuilder(
        stream: userStream,
        builder: (
          BuildContext context, 
          AsyncSnapshot<SUser> snapshot
        ) {
          if (!snapshot.hasData) {
            // _authentificationService.signOut();

            return const LoadingIndicator();
          }

          user = snapshot.data!;

          int? periodIndex = GetIt.I<SharedPreferences>().getInt('periodIndex');

          if (periodIndex == null) {
            periodIndex = 0;
            GetIt.I<SharedPreferences>().setInt('periodIndex', periodIndex);
          }

          String? lastUpdateChecked = GetIt.I<SharedPreferences>().getString('lastUpdateCheck');
          // if (true) {
          if (lastUpdateChecked != null && lastUpdateChecked != AppProperties.version) {
            // update popup
            Timer(
              const Duration(seconds: 1), 
              () {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return SConfirmationDialog(
                      icon: Icons.autorenew_rounded,
                      iconBackgroundColor: const Color.fromRGBO(76, 176, 81, 1), 
                      title: 'Mise à jour', 
                      content: 'Nouvelle version : ${databaseConsts.lastAppVersion}', 
                      confirmButtonTitle: 'Mettre à jour',
                      cancelButtonTitle: 'Plus tard',
                      onConfirm: () {
                        context.go('/settingsPage/aboutPage');
                      }
                    );
                  },
                );
                GetIt.I<SharedPreferences>().setString('lastUpdateCheck', AppProperties.version);
              }
            );
          }

          user.userData.settings.periodIndex = periodIndex;
          
          GetIt.I.registerSingleton<SUser>(user);
          GetIt.I.registerSingleton<Stream<SUser>>(userStream);

          return _pages.elementAt(_selectedDestination);
        }
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _onDestinationSelected,
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_rounded), 
            label: 'Accueil'
          ),
          const NavigationDestination(
            icon: Icon(Icons.group_rounded), 
            label: 'Amis'
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_rounded), 
            label: 'Classe'
          ),
          NavigationDestination(
            icon: Container(
              height: 24.0,
              width: 24.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/default-pfp.png')
                )
              ),
            ),
            label: user.userData.profile.username
          )
        ],
      ),
    );
  }
}
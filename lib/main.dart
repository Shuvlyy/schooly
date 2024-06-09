import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/initialization_page.dart';
import 'package:schooly/models/stheme.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/pages/authentification/registration/register_modal.dart';
import 'package:schooly/pages/authentification/registration/register_page.dart';
import 'package:schooly/pages/error_page.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/disciplines_page.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/discipline_pages/discipline_page.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/discipline_pages/edit_discipline_page.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/discipline_pages/grade_pages/grade_page.dart';
import 'package:schooly/pages/main/home_page/disciplines_pages/edit_disciplines_page.dart';
import 'package:schooly/pages/main/profile_page/edit_profile_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/about_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/account_settings_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/app_settings_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/language_settings_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/privacy_settings_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/pages/security_settings_page.dart';
import 'package:schooly/pages/main/profile_page/settings_pages/settings_page.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr-FR', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent
    )
  );

  await Firebase.initializeApp();

  final GetIt getIt = GetIt.instance;
  getIt.allowReassignment = true;
  getIt.registerSingleton<SUser>(SUser.empty());

  runApp(const App());
}

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      routes: <GoRoute>[
        GoRoute(
          path: 'error',
          builder: (
            BuildContext context,
            GoRouterState state
          ) => const ErrorPage()
        ),
        GoRoute(
          path: 'register',
          pageBuilder: (
            BuildContext context, 
            GoRouterState state
          ) {
            RegisterModal registerModal = state.extra as RegisterModal;

            if (registerModal.currentPage == 0) {
              Offset begin = const Offset(0.0, 1.0);
              Offset end = Offset.zero;
              Curve curve = Curves.ease;
              Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return CustomTransitionPage(
                child: RegisterPage(registerModal: registerModal), 
                transitionsBuilder: (
                  BuildContext context, 
                  Animation<dynamic> animation, 
                  Animation<dynamic> secondaryAnimation, 
                  Widget child
                ) => SlideTransition(
                  position: animation.drive(tween),
                  child: child
                ),
              );
            }

            return MaterialPage(
              child: RegisterPage(registerModal: registerModal)
            );
          },
        ),

        GoRoute(
          path: 'averageGrade',
          pageBuilder: (
            BuildContext context, 
            GoRouterState state
          ) {
            Offset begin = const Offset(1.0, 0.0);
            Offset end = Offset.zero;
            Curve curve = Curves.ease;
            Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return CustomTransitionPage(
              child: const AverageGradePage(), 
              transitionsBuilder: (
                BuildContext context, 
                Animation<dynamic> animation, 
                Animation<dynamic> secondaryAnimation, 
                Widget child
              ) => SlideTransition(
                position: animation.drive(tween),
                child: child
              ),
            );
          },
          routes: <GoRoute>[
            GoRoute(
              path: 'editDisciplinesPage',
              pageBuilder: (
                BuildContext context, 
                GoRouterState state
              ) {
                return const MaterialPage(
                  child: EditDisciplinesPage()
                );
              },
            ),
            GoRoute(
              path: 'disciplinePage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                List<Object> parameters = state.extra as List<Object>;

                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: DisciplinePage(
                    disciplineIndex: parameters.elementAt(0) as int,
                  ), 
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              },
              routes: <GoRoute>[
                GoRoute(
                  path: 'editDisciplinePage',
                  pageBuilder: (
                    BuildContext context, 
                    GoRouterState state
                  ) {
                    List<Object> parameters = state.extra as List<Object>;

                    return MaterialPage(
                      child: EditDisciplinePage(disciplineIndex: parameters.elementAt(0) as int)
                    );
                  },
                ),
                GoRoute(
                  path: 'gradePage',
                  pageBuilder: (
                    BuildContext context,
                    GoRouterState state
                  ) {
                    List<Object> parameters = state.extra as List<Object>;

                    Offset begin = const Offset(1.0, 0.0);
                    Offset end = Offset.zero;
                    Curve curve = Curves.ease;
                    Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return CustomTransitionPage(
                      child: GradePage(
                        disciplineIndex: parameters.elementAt(0) as int,
                        gradeIndex: parameters.elementAt(1) as int,
                      ), 
                      transitionsBuilder: (
                        BuildContext context, 
                        Animation<dynamic> animation, 
                        Animation<dynamic> secondaryAnimation, 
                        Widget child
                      ) => SlideTransition(
                        position: animation.drive(tween),
                        child: child
                      ),
                    );
                  }
                )
              ]
            )
          ]
        ),

        // TODO: friends

        // TODO: class

        GoRoute(
          path: 'editProfilePage',
          pageBuilder: (
            BuildContext context,
            GoRouterState state
          ) {
            return const MaterialPage(
              child: EditProfilePage()
            );
          }
        ),

        GoRoute(
          path: 'settingsPage',
          pageBuilder: (
            BuildContext context, 
            GoRouterState state
          ) {
            return const MaterialPage(
              child: SettingsPage()
            );
          },
          routes: <GoRoute>[
            GoRoute(
              path: 'accountSettingsPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const AccountSettingsPage(), 
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
            GoRoute(
              path: 'securitySettingsPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const SecuritySettingsPage(),
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
            GoRoute(
              path: 'privacySettingsPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const PrivacySettingsPage(),
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
            GoRoute(
              path: 'languageSettingsPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const LanguageSettingsPage(),
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
            GoRoute(
              path: 'appSettingsPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const AppSettingsPage(),
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
            GoRoute(
              path: 'aboutPage',
              pageBuilder: (
                BuildContext context,
                GoRouterState state
              ) {
                Offset begin = const Offset(1.0, 0.0);
                Offset end = Offset.zero;
                Curve curve = Curves.ease;
                Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return CustomTransitionPage(
                  child: const AboutPage(), 
                  transitionsBuilder: (
                    BuildContext context, 
                    Animation<dynamic> animation, 
                    Animation<dynamic> secondaryAnimation, 
                    Widget child
                  ) => SlideTransition(
                    position: animation.drive(tween),
                    child: child
                  ),
                );
              }
            ),
          ]
        )
      ],
      builder: (
        BuildContext context, 
        GoRouterState state
      ) => const InitializationPage(),
    )
  ]
);

class App extends StatefulWidget {
  const App({ super.key });

  @override
  State<App> createState() => AppState();

  static AppState? of(BuildContext context) =>
    context.findRootAncestorStateOfType<AppState>();
}

class AppState extends State<App> {
  Future<SharedPreferences>? _sharedPreferences;

  ThemeMode? themeMode;

  SStatus updateTheme(int themeMode) {
    try {
      setState(() {
        switch (themeMode) {
          case 1: 
            this.themeMode = ThemeMode.light;
            break;
          case 2:
            this.themeMode = ThemeMode.dark;
            break;
          default:
            this.themeMode = ThemeMode.system;
            break;
        }
      });
      
      return SStatus.fromModel(SStatusModel.OK);
    } catch (e) {
      return SStatus.fromModel(SStatusModel.UNKNOWN);
    }
  }

  @override
  void initState() {
    _sharedPreferences = SharedPreferences.getInstance();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences sharedPreferences;

    return FutureBuilder<SharedPreferences>(
      future: _sharedPreferences,
      builder: (
        BuildContext context, 
        AsyncSnapshot<SharedPreferences> snapshot
      ) {
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SLogo(rotate: true)
              ],
            )
          );
        }

        sharedPreferences = snapshot.data as SharedPreferences;

        GetIt.I.registerSingleton<SharedPreferences>(sharedPreferences);

        // sharedPreferences.setInt('theme', 0);
        
        if (themeMode == null) {
          switch (sharedPreferences.getInt('theme')) {
            case 1: 
              themeMode = ThemeMode.light;
              break;
            case 2:
              themeMode = ThemeMode.dark;
              break;
            default:
              themeMode = ThemeMode.system;
              break;
          }
        }

        return StreamProvider<SUser?>.value(
          value: AuthentificationService().user,
          initialData: null,
          builder: (
            BuildContext context, 
            Widget? child
          ) {
            return MaterialApp.router(
              routerDelegate: _router.routerDelegate,
              routeInformationParser: _router.routeInformationParser,
              routeInformationProvider: _router.routeInformationProvider,
              title: AppProperties.title,
              theme: STheme(theme: 1).getThemeData(),
              darkTheme: STheme(theme: 2).getThemeData(),
              themeMode: themeMode,
            );
          },
        );
      },
    );
  }
}

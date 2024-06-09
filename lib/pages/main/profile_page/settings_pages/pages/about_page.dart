// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/database_consts.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/icons/social_networks_icons_icons.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/user/sbadge.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/information_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/clickable_tile.dart';
import 'package:schooly/widgets/tiles/user_tile.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flowder/flowder.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({ super.key });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  final List<List> ownerSocialNetworks = <List>[
    [
      SocialNetworksIcons.discord,
      const Color.fromRGBO(64, 78, 237, 1),
      'Discord',
      'https://www.discord.gg/9VuM7k75nZ'
    ],
    [
      SocialNetworksIcons.instagram,
      const Color.fromRGBO(215, 129, 65, 1),
      'Instagram',
      'https://www.instagram.com/shuvlyyy'
    ],
    [
      SocialNetworksIcons.tiktok,
      Colors.black,
      'Tiktok',
      'https://www.tiktok.com/@shuvlyy'
    ],
    [
      SocialNetworksIcons.twitch,
      const Color.fromRGBO(145, 70, 255, 1),
      'Twitch',
      'https://www.twitch.tv/shuvlyy'
    ],
    [
      SocialNetworksIcons.twitter,
      const Color.fromRGBO(28, 150, 232, 1),
      'Twitter',
      'https://twitter.com/Shuvly'
    ],
    [
      SocialNetworksIcons.youtube,
      const Color.fromRGBO(247, 0, 0, 1),
      'Youtube',
      'https://www.youtube.com/@shuvly'
    ]
  ];

  final List<String> betaTestersUids = <String>[
    // '9vvROVhGVlghsMDdNcgY48ZyjXg2', // temp, it's my own user lol xd ptdr sex
    '1xQ8GxAEH9g9a6rpZjMJ2ZUTOzt1', // Léo DURAND
    'W3YOCVhCtkSJHVCBodKxbHiZk902', // Ruru
    'y1M6F94V6FfLZn80CMb7vcr5uYJ2', // Jojo
    'hD6i5AfGePccklhAZr4HlgAV6tP2', // Ethan GOGER
    '28cuzQ5LrHVY1Dx2awDs2TeBfBg1', // Jaydan DION
    'FEK5JviMh9MS7vtokNfGRDf4ckx2', // Lydéric LEGAVRE
    'JbVQ9LsJOeMynhynvqv0uZDq0qd2', // Mathis BOURGUIGNON
    'yTHeuC0NkwNtt7eWwglc9dNDt212', // Ewen MEHAULT
    '6u1yZubh35XLNtsNJMNxWSMTQXG3', // Natasha BLANC
    'UM1Y13XLgwPhjpKylxl5uAh7Du02', // Foxy
    'MicpsaTc7OZVp2Qp2c588ZZEQHg1' // Gabriel D'AGATA
  ];

  Future<List<SUser>> getBetaTestersProfiles() async {
    List<SUser> betaTesters = [];

    for (String betaTesterUid in betaTestersUids) {
      betaTesters.add(await DatabaseService.getUserByUid(betaTesterUid));
    }

    return betaTesters;
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1)
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller, 
    curve: Curves.easeInOutCirc
  );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseConsts databaseConsts = GetIt.I<DatabaseConsts>();

    final bool isUpdateAvailable = databaseConsts.lastAppVersion != AppProperties.version;

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
            'Paramètres > À propos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          ClickableTile(
            icon: Icons.autorenew_rounded,
            iconBackgroundColor: 
              isUpdateAvailable
              ? const Color.fromRGBO(255, 179, 71, 1)
              : const Color.fromRGBO(76, 176, 81, 1),
            trailingIcon: 
              isUpdateAvailable
              ? Icons.download_rounded
              : null,
            trailingIconColor: 
              isUpdateAvailable
              ? const Color.fromRGBO(255, 179, 71, 1)
              : null,
            title: 'Version actuelle',
            subtitle: "${AppProperties.version} (${DateFormat('dd/MM/yyyy').format(AppProperties.versionReleaseDate)})",
            isTitleMain: false,
            onTap: () {
              // go to update page
              if (!isUpdateAvailable) {
                return showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return InformationPopup(
                      icon: Icons.autorenew_rounded,
                      iconBackgroundColor: const Color.fromRGBO(76, 176, 81, 1),
                      title: 'Mise à jour',
                      content: "Votre version est à jour. (${AppProperties.version})"
                    );
                  }
                );
              }

              return showDialog(
                context: context, 
                builder: (BuildContext context) {
                  bool loading = false;

                  bool isDownloading = false;
                  double downloadProgress = 0.0;

                  return StatefulBuilder(
                    builder: (
                      BuildContext context, 
                      Function(void Function()) setModalState
                    ) {
                      if (!loading) {
                        if (!_controller.isCompleted) {
                          _controller.animateTo(1).then((_) => _controller.stop()); // End animation
                        }
                      } else {
                        _controller.repeat();
                      }
                      
                      late DownloaderCore downloaderCore;

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)
                        ),

                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RotationTransition(
                              turns: _animation,
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(76, 176, 81, 1),
                                  borderRadius: BorderRadius.circular(12.5),
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                      color: Color.fromRGBO(76, 176, 81, 1),
                                      blurRadius: 4,
                                    )
                                  ]
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.autorenew_rounded,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 15.0),
                            
                            Text(
                              'Mise à jour',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)
                            )
                          ],
                        ),

                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Nouvelle version : ${databaseConsts.lastAppVersion} (${DateFormat('dd/MM/yyyy').format(databaseConsts.lastAppVersionReleaseDate)})",
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),

                            if (isDownloading) ... {
                              const SizedBox(height: 15.0),

                              Text(
                                "${SMath.formatSignificantFigures(downloadProgress*100)}%",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),

                              const SizedBox(height: 10.0),

                              LinearPercentIndicator(
                                padding: const EdgeInsets.all(0.0),
                                lineHeight: 3.0,
                                animation: false,
                                percent: downloadProgress,
                                backgroundColor: Colors.grey.shade300,
                                progressColor: Theme.of(context).primaryColor,
                                barRadius: const Radius.circular(1.5),
                              )
                            },

                            const SizedBox(height: 20.0),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (!isDownloading) ... {
                                  SButton(
                                    icon: Icons.autorenew_rounded,
                                    title: 'Mettre à jour',
                                    backgroundColor: const Color.fromRGBO(76, 176, 81, 1),
                                    onTap: () async {
                                      setModalState(() {
                                        loading = true;
                                      });

                                      final PermissionStatus storagePermission = await Permission.storage.request();

                                      if (storagePermission.isDenied) {
                                        setModalState(() {
                                          loading = false;
                                        });
                                        
                                        return showDialog(
                                          context: context, 
                                          builder: (BuildContext context) {
                                            return const InformationPopup(
                                              content: '''
  Une mise à jour ne peut s'effectuer sans la permission d'accéder au stockage du téléphone.\nVeuillez réessayer.'''
                                            );
                                          },
                                        );
                                      }

                                      if (storagePermission.isPermanentlyDenied || !storagePermission.isGranted) {
                                        setModalState(() {
                                          loading = false;
                                        });

                                        openAppSettings();

                                        return Fluttertoast.showToast(
                                          msg: '''
  Une mise à jour ne peut s'effectuer sans la permission d'accéder au stockage du téléphone.\nVeuillez l'accepter.''',
                                          backgroundColor: Colors.black.withOpacity(.5),
                                          fontSize: 16.0,
                                          toastLength: Toast.LENGTH_LONG
                                        );
                                      }

                                      final Directory tempDirectory = await getTemporaryDirectory();

                                      final String downloadFilePath = "${tempDirectory.path}/Schooly ${databaseConsts.lastAppVersion}.apk";

                                      final DownloaderUtils downloaderUtils = DownloaderUtils(
                                        progress: ProgressImplementation(), 
                                        file: File(downloadFilePath), 
                                        onDone: () async {
                                          setModalState(() {
                                            loading = false;
                                            isDownloading = false;
                                            downloadProgress = 0.0;
                                          });

                                          try {
                                            await AppInstaller.installApk(downloadFilePath);
                                          } catch (exception) {
                                            setModalState(() {
                                              loading = false;
                                            });

                                            showDialog(
                                              context: context, 
                                              builder: (BuildContext context) {
                                                return const InformationPopup(
                                                  icon: Icons.close_rounded,
                                                  iconBackgroundColor: Colors.red,
                                                  title: 'Erreur',
                                                  content: 'Une erreur est survenue pendant l\'installation, veuillez recommencer ultérieurement.'
                                                );
                                              },
                                            );
                                          }
                                        }, 
                                        progressCallback: (
                                          int count, 
                                          int total
                                        ) {
                                          try {
                                            setModalState(() {
                                              downloadProgress = count/total;
                                            });
                                          } catch (exception) {
                                            try {
                                              downloaderCore.cancel();

                                              setModalState(() {
                                                loading = false;
                                                isDownloading = false;
                                                downloadProgress = 0.0;
                                              });
                                            } catch (exception) {
                                              showDialog(
                                                context: context, 
                                                builder: (BuildContext context) {
                                                  return ErrorPopup(error: SStatus.fromModel(SStatusModel.UNKNOWN));
                                                },
                                              );
                                            }
                                          }
                                        },
                                        deleteOnCancel: true,
                                      );

                                      setModalState(() {
                                        isDownloading = true;
                                        downloadProgress = 0.0;
                                      });

                                      downloaderCore = await Flowder.download(
                                        databaseConsts.lastVersionApkLink.toString(), 
                                        downloaderUtils
                                      );
                                    }
                                  )
                                } else ... {
                                  // SButton(
                                  //   icon: isDownloading ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  //   backgroundColor: Colors.transparent,
                                  //   onTap: () {
                                  //     try {
                                  //       if (isDownloading) {
                                  //         downloaderCore.pause();
                                  //       } else {
                                  //         downloaderCore.resume();
                                  //       }

                                  //       setState(() {
                                  //         isDownloading = !isDownloading;
                                  //       });
                                  //     } catch (exception) {
                                  //       print(exception);
                                  //     } // TODO: Maybe show a toast message that explains the error?
                                  //   }
                                  // ),

                                  // const SizedBox(width: 10.0),

                                  // SButton(
                                  //   icon: Icons.stop_rounded,
                                  //   backgroundColor: Colors.red,
                                  //   onTap: () {
                                  //     try {
                                  //       downloaderCore.cancel();

                                  //       setModalState(() {
                                  //         loading = false;
                                  //         isDownloading = false;
                                  //         downloadProgress = 0.0;
                                  //       });
                                  //     } catch (exception) {
                                  //       print(exception);
                                  //     } // TODO: Maybe show a toast message that explains the error?
                                  //   }
                                  // )
                                }
                              ],
                            )
                          ],
                        )
                      );
                    },
                  );
                },
              );
            },
          ),

          ClickableTile(
            icon: Icons.discord,
            iconBackgroundColor: const Color.fromRGBO(64, 78, 237, 1),
            title: 'Discord',
            subtitle: 'discord.gg/schooly', // TODO: change the link for the real one
            onTap: () async {
              if (await canLaunchUrlString(ownerSocialNetworks[0][3])) {
                Fluttertoast.showToast(
                  msg: 'Le serveur Discord de Schooly n\'est pas encore fini. En attendant, voici le mien ! :)',
                  backgroundColor: Colors.black.withOpacity(.5),
                  fontSize: 16.0,
                  toastLength: Toast.LENGTH_LONG
                );
                await launchUrlString(ownerSocialNetworks[0][3], mode: LaunchMode.externalApplication);
              }
            },
          ),

          const SizedBox(height: 10.0),

          const Separator(),

          const SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Créateur',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500
                  ),
                ),

                const SizedBox(height: 10.0),

                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 86.0,
                      width: 86.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(39.0),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/a/AAcHTtds1qRgoxH9-MyrNr_KSIZpWH7Y89hPYSggMJPHH42zAZw=s172-c-no',
                          loadingBuilder: (
                            BuildContext context, 
                            Widget child, 
                            ImageChunkEvent? loadingProgress
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }
                    
                            return Container(
                              color: SColors.getGreyscaleColor(context).withOpacity(0.1)
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Shuvly',
                            style: Theme.of(context).textTheme.titleLarge
                          ),

                          Text(
                            '@shuvly',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: SColors.getInvertedGreyscaleColor(context)
                            ),
                          ),
                          
                          Wrap(
                            children: <SBadgeWidget>[
                              for (List socialNetwork in ownerSocialNetworks) ... {
                                SBadgeWidget(
                                  icon: socialNetwork[0],
                                  iconColor: socialNetwork[1],
                                  title: socialNetwork[2],
                                  onTap: () async {
                                    if (await canLaunchUrlString(socialNetwork[3])) {
                                      await launchUrlString(socialNetwork[3], mode: LaunchMode.externalApplication);
                                    }
                                  },
                                )
                              },
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20.0),

                Text(
                  'Bêta Testeurs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500
                  ),
                ),

                const SizedBox(height: 10.0)
              ],
            )
          ),

          FutureBuilder(
            future: getBetaTestersProfiles(),
            builder: (
              BuildContext context, 
              AsyncSnapshot<List<SUser>> snapshot
            ) {
              if (!snapshot.hasData) {
                return Column(
                  children: List.generate(betaTestersUids.length, (int index) => UserTile.shimmerLoading(context)),
                );
              }

              List<SUser> betaTesters = snapshot.data ?? [];

              return Column(
                children: List.generate(
                  betaTesters.length, 
                  (int index) {
                    return UserTile(user: betaTesters.elementAt(index));
                  }
                ),
              );
            },
          )
        ],
      )
    );
  }
}
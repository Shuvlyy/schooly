// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/database_consts.dart';
import 'package:schooly/common/smath.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/widgets/buttons/sbutton.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/popups/information_popup.dart';
import 'package:schooly/widgets/slogo.dart';

class OutdatedAppPage extends StatefulWidget {
  const OutdatedAppPage({super.key});

  @override
  State<OutdatedAppPage> createState() => _OutdatedAppPageState();
}

class _OutdatedAppPageState extends State<OutdatedAppPage> with TickerProviderStateMixin {
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
    
    return GradientScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[ // TODO: Maybe change this gradient ?
          Color.fromRGBO(255, 137, 137, 1),
          Color.fromRGBO(131, 0, 0, 1)
        ]
      ),
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SLogo(size: 75.0),
                const SizedBox(width: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Text>[
                    Text(
                      AppProperties.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      "${AppProperties.version} (${DateFormat('dd/MM/yyyy').format(AppProperties.versionReleaseDate)})",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color.fromRGBO(206, 206, 206, 1)
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 60.0),
            Text(
              '''
La version actuelle de votre application
(${AppProperties.version}) n’est pas compatible avec la
base de données.\n
Veuillez mettre à jour votre application.''',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SButton(
                  icon: Icons.autorenew_rounded,
                  title: 'Mettre à jour',
                  backgroundColor: const Color.fromRGBO(76, 176, 81, 1),
                  onTap: () {
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
                                                      }
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
                                        //     } // TODO: Maybe show a toast message that explains the error ?
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
                                        //     } // TODO: Maybe show a toast message that explains the error ?
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
                  }
                )
              ]
            )
          ],
        ),
      ),
    );
  }
}
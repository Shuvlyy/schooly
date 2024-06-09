// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/dialogs/sconfirmationdialog.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/grades/grade.dart';
import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/sbadge.dart';
import 'package:schooly/models/user/studentinfo.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/authentification_service.dart';
import 'package:schooly/widgets/buttons/appbar_popup_menu_button.dart';
import 'package:schooly/widgets/clickable_text.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popup_menu_single_item.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/separator.dart';
import 'package:schooly/widgets/tiles/clickable_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final Stream<SUser> userStream = GetIt.I<Stream<SUser>>();

    return StreamBuilder(
      stream: userStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<SUser> snapshot
      ) {
        SUser user = GetIt.I<SUser>();

        if (snapshot.hasData) {
          GetIt.I.registerSingleton<SUser>(snapshot.data!);
        }
        
        final double averageGrade = user.userData.getAverageGrade();

        final SProfile userProfile = user.userData.profile;
        final LocationInformations userLocationInformations = userProfile.locationInformations;
        final StudentInformations userStudentInformations = userProfile.studentInformations;

        return GradientScaffold(
          gradient: SColors.getScaffoldGradient(context),
          appBar: SAppBar(
            title: SLogo(rotate: loading),
            actions: [
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                child: const AppbarPopupMenuButton(),
                itemBuilder: (BuildContext context) =>
                  [
                    const PopupMenuItem(
                      value: 'editProfile',
                      child: PopupMenuSingleItem(
                        text: 'Modifier le profil', 
                        icon: Icons.edit_rounded
                      )
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: PopupMenuSingleItem(
                        text: 'Paramètres',
                        icon: Icons.settings_rounded,
                      )
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: PopupMenuSingleItem(
                        text: 'Se déconnecter', 
                        icon: Icons.logout_rounded
                      )
                    )
                  ],
                onSelected: (String? value) {
                  switch (value) {
                    case 'editProfile':
                      context.go('/editProfilePage');
                      break;
                    case 'settings':
                      context.go('/settingsPage');
                      break;
                    case 'logout':
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return SConfirmationDialog(
                            icon: Icons.logout_rounded, 
                            iconBackgroundColor: Colors.red,
                            title: 'Déconnexion', 
                            content: 'Êtes-vous sûr de vouloir vous déconnecter ?', 
                            cancelButtonTitle: 'Non',
                            onConfirm: () async {
                              setState(() {
                                loading = true;
                              });

                              SStatus signOutStatus = await AuthentificationService().signOut();

                              setState(() {
                                loading = false;
                              });

                              if (signOutStatus.failed) {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return ErrorPopup(error: signOutStatus);
                                  }
                                );
                              }
                            }
                          );
                        },
                      );

                      break;
                    default:
                      break;
                  }
                },
              )
            ],
          ),
          body: DefaultPageLayout(
            // gradient: <Color>[ // TODO: make the gradient page-wide
            //   Colors.grey.shade300,
            //   Colors.grey.shade800
            // ],
            body: <Widget>[
              Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  CircularPercentIndicator(
                    percent: Grade(grade: averageGrade).toPercentage,
                    lineWidth: 3.0,
                    radius: 43.0,
                    backgroundColor: Colors.transparent,
                    progressColor: Grade(grade: averageGrade).color,
                    animation: true,
                    animationDuration: 400,
                    circularStrokeCap: CircularStrokeCap.round,
                    curve: Curves.easeInOut,
                    center: Container(
                      height: 80.0,
                      width: 80.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/images/default-pfp.png')
                        )
                      ),
                    )
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userProfile.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "@${userProfile.username}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: SColors.getInvertedGreyscaleColor(context)
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Wrap(
                          children: <Widget>[
                            for (SBadge badge in user.userData.profile.badges) ... {
                              badge.widget
                            }
                          ],
                        ),
                      ],
                      
                    ),
                  )
                ]
              ),
              const Separator(),
              Column(
                children: <ClickableTile>[
                  ClickableTile(
                    icon: Icons.location_on_rounded,
                    iconBackgroundColor: const Color.fromRGBO(158, 189, 219, 1), 
                    title: 'Localisation',
                    subtitle: userLocationInformations.display, 
                    isTitleMain: false,
                  ),
                  ClickableTile(
                    icon: Icons.groups_rounded, 
                    iconBackgroundColor: const Color.fromRGBO(237, 152, 152, 1),
                    title: 'Classe',
                    subtitle: userStudentInformations.gradeClassDisplay,
                    isTitleMain: false,
                  ),
                  ClickableTile(
                    icon: Icons.business_rounded, 
                    iconBackgroundColor: const Color.fromRGBO(200, 200, 200, 1),
                    title: 'Établissement',
                    subtitle: userStudentInformations.establishmentDisplay,
                    isTitleMain: false,
                  )
                ],
              )
            ],
            trailing: Column(
              children: <Widget>[
                Material(
                  color: SColors.getBackgroundColor(context),
                  child: ClickableText(
                    text: Text(
                      "A rejoint le ${userProfile.formattedJoinedAt}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SColors.getGreyscaleColor(context)
                      ),
                    ),
                    tooltip: DateFormat("dd/MM/yyyy hh:mm:ss").format(user.userData.profile.joinedAt!),
                  ),
                ),
                // const SizedBox(height: 5.0),
                // Text(
                //   "UID : ${user.uid}",
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //     color: SColors.getGreyscaleColor(context)
                //   ),
                // )
              ],
            ),
          ),
        );
      }
    );
  }
}
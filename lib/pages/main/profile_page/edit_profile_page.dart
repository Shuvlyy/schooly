// ignore_for_file: use_build_context_synchronously

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:schooly/common/app_properties.dart';
import 'package:schooly/common/regexes.dart';
import 'package:schooly/common/scolors.dart';
import 'package:schooly/common/sstatus.dart';
import 'package:schooly/layouts/default_page_layout.dart';
import 'package:schooly/models/user/locationinfo.dart';
import 'package:schooly/models/user/profile.dart';
import 'package:schooly/models/user/studentinfo.dart';
import 'package:schooly/models/user/suser.dart';
import 'package:schooly/services/database_service.dart';
import 'package:schooly/widgets/buttons/appbar_leading.dart';
import 'package:schooly/widgets/buttons/dialog_button.dart';
import 'package:schooly/widgets/gradient_scaffold.dart';
import 'package:schooly/widgets/slogo.dart';
import 'package:schooly/widgets/popups/error_popup.dart';
import 'package:schooly/widgets/sappbar.dart';
import 'package:schooly/widgets/textfields/text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController displayNameFieldController = TextEditingController();
  final TextEditingController usernameFieldController = TextEditingController();
  String country = '';
  String state = '';
  String city = '';
  final TextEditingController gradeClassFieldController = TextEditingController();
  final TextEditingController establishmentFieldController = TextEditingController();

  bool loading = false;
  bool firstLoading = true;

  bool usernameVerificationLoading = false;
  bool? isUsernameTaken;

  @override
  void dispose() {
    displayNameFieldController.dispose();
    usernameFieldController.dispose();
    gradeClassFieldController.dispose();
    establishmentFieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SUser user = GetIt.I<SUser>();

    final SProfile userProfile = user.userData.profile;
    final LocationInformations userLocationInformations = userProfile.locationInformations;
    final StudentInformations userStudentInformations = userProfile.studentInformations;

    if (firstLoading) {
      displayNameFieldController.text = userProfile.displayName;
      usernameFieldController.text = userProfile.username;

      if (userLocationInformations.country.isNotEmpty) {
        try {
          country = "${userLocationInformations.country.substring(0,4)}    ${userLocationInformations.country.substring(5)}";
        } catch (e) {
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return ErrorPopup(
                error: SStatus.fromModel(SStatusModel.UNKNOWN)
              );
            },
          );
        }
      }

      state = userLocationInformations.state;
      city = userLocationInformations.city;
      gradeClassFieldController.text = userStudentInformations.gradeClass;
      establishmentFieldController.text = userStudentInformations.establishment;

      firstLoading = false;
    }

    return GradientScaffold(
      gradient: SColors.getScaffoldGradient(context),
      appBar: SAppBar(
        leading: AppBarLeadingButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: () {
            context.pop();
          }
        ),
        title: SLogo(rotate: loading)
      ),
      body: DefaultPageLayout(
        body: <Widget>[
          Text(
            'Modifier le profil',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24.0,
              fontWeight: FontWeight.w500
            ),
          ),

          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Soon...')
                )
              );
            },
            borderRadius: BorderRadius.circular(46.0),
            child: Container(
              height: 92.0,
              width: 92.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/images/default-pfp.png')
                )
              ),
            ),
          ),

          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                STextField(
                  labelText: 'Pseudo', 
                  controller: displayNameFieldController, 
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un pseudo';
                    }

                    if (value.length > AppProperties.maxDisplayNameLength) {
                      return "Votre pseudo ne peut contenir que ${AppProperties.maxDisplayNameLength}";
                    }
                  },
                ),

                const SizedBox(height: 10.0),

                STextField(
                  labelText: 'Nom d\'utilisateur', 
                  leading: const Icon(Icons.alternate_email_rounded),
                  trailing: 
                    isUsernameTaken == null 
                    ? null
                    : (
                      usernameVerificationLoading
                      ? const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(),
                      )
                      : (
                        isUsernameTaken!
                        ? const Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                        )
                        : const Icon(
                          Icons.check_rounded,
                          color: Colors.green,
                        )
                      )
                    ),
                  controller: usernameFieldController, 
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom d\'utilisateur';
                    }

                    if (value.length > AppProperties.maxUsernameLength) {
                      return "Votre pseudo ne peut contenir que ${AppProperties.maxUsernameLength} caractères";
                    }

                    if (!Regexes.username.hasMatch(value)) {
                      return "Veuillez entrer un nom d'utilisateur valide.\n(uniquement des minuscules, chiffres et underscores \"_\")";
                    }
                  }
                )
              ],
            ),
          ),

          CSCPicker(
            countryDropdownLabel: 'Pays',
            stateDropdownLabel: 'Région',
            cityDropdownLabel: 'Ville',
            countrySearchPlaceholder: 'Rechercher un pays',
            stateSearchPlaceholder: 'Rechercher une région',
            citySearchPlaceholder: 'Rechercher une ville',
            currentCountry: country.isEmpty ? null : country,
            currentState: state.isEmpty ? null : state,
            currentCity: city.isEmpty ? null : city,
            flagState: CountryFlag.ENABLE,
            dropdownDecoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(206, 206, 206, 1),
                width: 2.0
              ),
              borderRadius: BorderRadius.circular(15.0)
            ),
            disabledDropdownDecoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: const Color.fromRGBO(206, 206, 206, 1),
                width: 2.0
              ),
              borderRadius: BorderRadius.circular(15.0)
            ),
            searchBarRadius: 15.0,
            dropdownHeadingStyle: 
              Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500
              ),
            onCountryChanged: (String country) {
              this.country = country;
              state = '';
              city = '';
            },
            onStateChanged: (String? state) {
              if (state == null) return;

              this.state = state;
              city = '';
            },
            onCityChanged: (String? city) {
              if (city == null) return;

              this.city = city;
            },
          ),

          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Flexible(
                child: STextField(
                  labelText: 'Classe', 
                  controller: gradeClassFieldController, 
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une classe';
                    }
                  }
                )
              ),
              const SizedBox(width: 10.0),
              Flexible(
                flex: 2,
                child: STextField(
                  labelText: 'Établissement', 
                  controller: establishmentFieldController, 
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un établissement';
                    }
                  }
                )
              )
            ],
          )
        ],
        trailing: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            DialogButton(
              style: DialogButtonStyle.secondary, 
              text: 'Annuler', 
              onTap: () {
                context.pop();
              }
            ),

            const SizedBox(width: 10.0),

            DialogButton(
              style: DialogButtonStyle.primary, 
              text: 'Sauvegarder', 
              onTap: () async {
                if (formKey.currentState == null) return;

                if (!formKey.currentState!.validate()) return;

                // TODO: if nothing changed, just context.pop()

                if (country.isEmpty || state.isEmpty || city.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner un pays, une région et une ville')
                    )
                  );
                  return;
                }

                setState(() {
                  loading = true;
                });

                if (
                  usernameFieldController.text == '' || 
                  usernameFieldController.text.length > AppProperties.maxDisplayNameLength
                ) {
                  return;
                }

                if (usernameFieldController.text != user.userData.profile.username) {
                  setState(() => usernameVerificationLoading = true);

                  bool doesUsernameExists = await DatabaseService.doesUsernameExists(usernameFieldController.text);

                  setState(() {
                    isUsernameTaken = doesUsernameExists;
                    usernameVerificationLoading = false;
                  });

                  if (doesUsernameExists) {
                    setState(() {
                      loading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ce nom d\'utilisateur est déjà pris.')
                      )
                    );

                    return;
                  }
                }

                final SProfile oldProfile = user.userData.profile;

                setState(() {
                  user.userData.profile.displayName = displayNameFieldController.text;
                  user.userData.profile.username = usernameFieldController.text;

                  user.userData.profile.locationInformations = LocationInformations(
                    country: "${country.substring(0, 4)} ${country.substring(8)}",
                    state: state,
                    city: city
                  );

                  user.userData.profile.studentInformations = StudentInformations(
                    gradeClass: gradeClassFieldController.text,
                    establishment: establishmentFieldController.text
                  );
                });

                SStatus result = await DatabaseService(uid: user.uid).saveUser(user);

                if (result.failed) {
                  setState(() {
                    user.userData.profile.replaceWith(oldProfile);
                  });

                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return ErrorPopup(error: result);
                    },
                  );
                }
                
                setState(() {
                  loading = false;
                });

                context.pop();
              }
            )
          ],
        ),
      )
    );
  }
}
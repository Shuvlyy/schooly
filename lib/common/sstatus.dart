// ignore_for_file: constant_identifier_names

class SStatus {
  String string; // Error code as string
  String hex; // Error code as hex
  String message; // Error code as message
  bool failed; // If request has failed

  SStatus({
    required this.string,
    this.hex = '',
    this.message = '',
    this.failed = false
  });

  static SStatus fromModel(SStatusModel error) {
    switch (error) {
      case SStatusModel.OK:
        return SStatus(string: 'OK');
      case SStatusModel.PENDING:
        return SStatus(string: 'PENDING');

      // Database (DB), 0x* //
      case SStatusModel.DB_ERR_NO_RESPONSE:
        return SStatus(
          string: 'DB_ERR_NO_RESPONSE', 
          hex: '0x01', 
          message: 'La base de données ne répond pas. Veuillez vérifier votre connexion Internet ou réessayez ultérieurement. Si le problème persiste, veuillez contacter @Shuvly sur Twitter ou un autre réseau.', 
          failed: true
        );
      case SStatusModel.DB_ERR_TOO_MANY_REQUESTS:
        return SStatus(
          string: 'DB_ERR_TOO_MANY_REQUESTS', 
          hex: '0x02', 
          message: 'Ralentissez ! Vous effectuez trop de requêtes vers la base de données.', 
          failed: true
        );
      case SStatusModel.DB_ERR_UNAUTHORIZED:
        return SStatus(
          string: 'DB_ERR_UNAUTHORIZED', 
          hex: '0x03', 
          message: "La version actuelle de votre application (${0.3}) n'est pas autorisée à accéder à la base de données. Veuillez mettre à jour votre application.", 
          failed: true
        );
      case SStatusModel.DB_ERR_STRUCTURE_MISMATCH:
        return SStatus(
          string: 'DB_ERR_STRUCTURE_MISMATCH', 
          hex: '0x04',
          message: "La version actuelle de votre application (${0.3}) n'est pas compatible avec la base de données. Veuillez mettre à jour votre application.",
          failed: true
        );
      //

      // Network (NET), 1x* //
      case SStatusModel.NET_ERR_NO_CONNECTION:
        return SStatus(
          string: 'NET_ERR_NO_CONNECTION', 
          hex: '1x01', 
          message: 'La connexion Internet a été perdue. Veuillez vous connecter à un réseau Internet.', 
          failed: true
        );
      case SStatusModel.NET_ERR_URL_LAUNCH:
        return SStatus(
          string: 'NET_ERR_URL_LAUNCH', 
          hex: '1x02', 
          message: "La page internet n'a pas pu être lancée. Veuillez recommencer ultérieurement.",
          failed: true
        );
      //

      // Authentification (AUTH), 2x* //
      case SStatusModel.AUTH_ERR_WRONG_CREDENTIALS_EMAIL:
        return SStatus(
          string: 'AUTH_ERR_WRONG_CREDENTIALS_EMAIL', 
          hex: '2x01', 
          message: "Cette adresse e-mail n'est pas enregistrée sur Schooly.", 
          failed: true
        );
      case SStatusModel.AUTH_ERR_WRONG_CREDENTIALS_PASSWORD:
        return SStatus(
          string: 'AUTH_ERR_WRONG_CREDENTIALS_PASSWORD', 
          hex: '2x02', 
          message: 'Mot de passe incorrect !', 
          failed: true
        );
      case SStatusModel.AUTH_ERR_USERNAME_TAKEN:
        return SStatus(
          string: 'AUTH_ERR_USERNAME_TAKEN',
          hex: '2x03',
          message: "Ce nom d'utilisateur est déjà pris.",
          failed: true
        );
      case SStatusModel.AUTH_ERR_ALREADY_REGISTERED:
        return SStatus(
          string: 'AUTH_ERR_ALREADY_REGISTERED',
          hex: '2x04',
          message: 'Cette adresse e-mail correspond déjà à un compte sur Schooly.', //(@{user}).",
          failed: true
        );
      //

      // Client (CL), 3x* //
      case SStatusModel.CL_ERR_DISC_LIMIT_REACHED:
        return SStatus(
          string: 'CL_ERR_DISC_LIMIT_REACHED',
          hex: '3x01',
          message: "La limite de ${20} matières à été atteinte.",
          failed: true
        );
      //

      // User (USER), 4x* //
      case SStatusModel.USER_FRN_PRIVATE:
        return SStatus(
          string: 'USER_FRN_PRIVATE',
          hex: '4x01',
          message: 'Cet utilisateur est privé.',
          failed: true
        );
      
      case SStatusModel.USER_FRN_REQUESTS_CLOSED:
        return SStatus(
          string: 'USER_FRN_REQUESTS_CLOSED',
          hex: '4x02',
          message: "Cet utilisateur n'accepte pas les demandes d'ami.",
          failed: true
        );

      case SStatusModel.USER_FRN_ALREADY_ASKED:
        return SStatus(
          string: 'USER_FRN_ALREADY_ASKED',
          hex: '4x03',
          message: "Vous avez déjà demandé cet utilisateur en ami, attendez qu'il vous réponde !",
          failed: true
        );
      //

      case SStatusModel.UNKNOWN:
        return SStatus(
          string: 'ERR', 
          hex: '69x00', 
          message: 'Une erreur inconnue est survenue.', 
          failed: true
        );
      default:
        return SStatus(
          string: 'ERROR', 
          hex: '69x69', 
          message: 'Une erreur encore plus inconnue est survenue.', 
          failed: true
        );
    }
  }

  SStatusModel toModel() {
    return SStatusModel.values.firstWhere((element) => element.toString() == string);
  }
}

enum SStatusModel {
  OK,
  PENDING,

  // Database (DB), 0x* //
  DB_ERR_NO_RESPONSE, // 0x01
  DB_ERR_TOO_MANY_REQUESTS, // 0x02
  DB_ERR_UNAUTHORIZED, // 0x03
  DB_ERR_STRUCTURE_MISMATCH, // 0x04
  //

  // Network (NET), 1x* //
  NET_ERR_NO_CONNECTION, // 1x01
  NET_ERR_URL_LAUNCH, // 1x04
  //

  // Authentification (AUTH), 2x* //
  AUTH_ERR_WRONG_CREDENTIALS_EMAIL, // 2x01
  AUTH_ERR_WRONG_CREDENTIALS_PASSWORD, // 2x02
  AUTH_ERR_USERNAME_TAKEN, // 2x03
  AUTH_ERR_ALREADY_REGISTERED, // 2x03
  //

  // Client (CL), 3x* //
  CL_ERR_DISC_LIMIT_REACHED, // 3x01
  //

  // User (USER), 4x* //
  USER_FRN_PRIVATE, // 4x01
  USER_FRN_REQUESTS_CLOSED, // 4x02
  USER_FRN_ALREADY_ASKED, // 4x03
  //

  UNKNOWN
}
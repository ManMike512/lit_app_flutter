const authUrl = 'https://auth.literotica.com/';
const apiUrl = 'https://literotica.com/api/3/';
const apiUrlV1 = 'https://literotica.com/api/1/';
const litUrl = 'https://literotica.com/';

const app_id = '24b7c3f9d904ebd679299b1ce5506bc305a5ab40';
const api_key = '70b3a71911b398a98d3dac695f34cf279c270ea0';

enum LoginState { loggedOut, loading, loggedIn, failure }

enum SearchSortField { relevant, dateAsc, dateDesc, voteAsc, voteDesc, commentsAsc, commentsDesc }

class SearchString {
  // ignore: constant_identifier_names
  static const String? relevant = null;
  // ignore: constant_identifier_names
  static const String dateAsc = 'date asc';
  // ignore: constant_identifier_names
  static const String dateDesc = 'date desc';
  // ignore: constant?_identifier_names
  static const String voteAsc = 'vote asc';

  // ignore: constant?_identifier_names
  static const String voteDesc = 'vote desc';
  // ignore: constant?_identifier_names
  static const String commentsAsc = 'comments asc';
  // ignore: constant?_identifier_names
  static const String commentsDesc = 'comments desc';
}

enum AuthorGender {
  male,
  female,
  couple,
  transgender,
  transgenderFemale,
  transgenderMale,
  intersex,
  genderQueer,
  genderless,
  differentIdentity,
}

extension AuthorGenderExtension on AuthorGender {
  // Get the text representation
  String get text {
    switch (this) {
      case AuthorGender.male:
        return 'Male';
      case AuthorGender.female:
        return 'Female';
      case AuthorGender.couple:
        return 'Couple';
      case AuthorGender.transgender:
        return 'Transgender';
      case AuthorGender.transgenderFemale:
        return 'Transgender Female';
      case AuthorGender.transgenderMale:
        return 'Transgender Male';
      case AuthorGender.intersex:
        return 'Intersex';
      case AuthorGender.genderQueer:
        return 'Gender Queer';
      case AuthorGender.genderless:
        return 'Genderless';
      case AuthorGender.differentIdentity:
        return 'Different Identity';
    }
  }

  // Get the API parameter value
  String get apiValue {
    switch (this) {
      case AuthorGender.male:
        return 'm';
      case AuthorGender.female:
        return 'f';
      case AuthorGender.couple:
        return 'c';
      case AuthorGender.transgender:
        return 't';
      case AuthorGender.transgenderFemale:
        return 'o';
      case AuthorGender.transgenderMale:
        return 'p';
      case AuthorGender.intersex:
        return 'i';
      case AuthorGender.genderQueer:
        return 'q';
      case AuthorGender.genderless:
        return 'l';
      case AuthorGender.differentIdentity:
        return 'd';
    }
  }
}

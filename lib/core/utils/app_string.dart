// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class AppString {
  factory AppString() => _instance;

  AppString._initials();
  static final AppString _instance = AppString._initials();

  //storage key here
  static const String ACCESS_TOKEN = "access_token";


}

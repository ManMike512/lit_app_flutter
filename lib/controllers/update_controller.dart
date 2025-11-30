import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lit_reader/env/global.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateController extends GetxController {
  final _isUpdateAvailable = false.obs;
  bool get isUpdateAvailable => _isUpdateAvailable.value;
  set isUpdateAvailable(bool value) {
    _isUpdateAvailable.value = value;
  }

  final _latestVersion = versionString.obs;
  String get latestVersion => _latestVersion.value;
  set latestVersion(String value) {
    _latestVersion.value = value;
  }

  String get currentVersion => versionString;

  Future<void> checkForUpdate() async {
    const repoOwner = 'ManMike512';
    const repoName = 'lit_app_flutter';
    final url = 'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';
    print('Checking for updates at $url');

    try {
      Dio dio = Dio();
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        String? latestVersion = data['tag_name']?.replaceFirst('v', '');
        if (latestVersion == null) {
          print('Latest version tag not found in the response.');
          isUpdateAvailable = false;
          return;
        }
        int indexOfPlus = latestVersion.indexOf('+');
        latestVersion = latestVersion.substring(0, indexOfPlus >= 0 ? indexOfPlus : latestVersion.length);
        this.latestVersion = latestVersion;
        print('Current version: $currentVersion, Latest version: $latestVersion');
        if (latestVersion != currentVersion) {
          isUpdateAvailable = true;
        } else {
          isUpdateAvailable = false;
        }
      } else {
        isUpdateAvailable = false;
      }
    } catch (e) {
      print('Error checking for updates: $e');
      isUpdateAvailable = false;
    }
  }

  Future<void> launchUpdateURL() async {
    const repoOwner = 'ManMike512';
    const repoName = 'lit_app_flutter';
    final url = Uri.parse('https://github.com/$repoOwner/$repoName/releases/latest');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}

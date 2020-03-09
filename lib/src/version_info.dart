import 'dart:io';

class VersionInfo {
  final String newVersion;
  final bool updateAvaible;
  final String appId;

  Platform get platform {
    return Platform();
  }

  VersionInfo({this.newVersion, this.updateAvaible, this.appId});
}

import 'dart:io';

class VersionInfo {
  final String newVersion;
  final bool updateAvaible;

  Platform get platform {
    return Platform();
  }

  VersionInfo({this.newVersion, this.updateAvaible});
}

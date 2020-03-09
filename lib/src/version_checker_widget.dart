import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info/package_info.dart';
import 'package:rx_command/rx_command.dart';
import 'package:status_handler/status_handler.dart';
import 'package:upgrader/upgrader.dart';

class VersionCheckerManager with WidgetStatusMixin {
  RxCommand<void, bool> checkUpdate;

  VersionCheckerManager() {
    checkUpdate = RxCommand.createAsyncNoParam(() async {
      if (Platform.isAndroid) {
        //* Android
        final AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
        return Future.value(appUpdateInfo.updateAvailable);
      } else {
        //* Get instaled app version
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();

        //* iOS
        final iTunes = ITunesSearchAPI();

        final results = await iTunes.lookupByBundleId(packageInfo.packageName);

        final versionInfo = ITunesResults.version(results);

        final int storeVesion = int.parse(versionInfo.replaceAll(".", ""));
        final int localVersion = int.parse(packageInfo.version.replaceAll(".", ""));

        return Future.value(storeVesion != localVersion);
      }
    })
      ..listen((updateAvaible) {
        statusDone();
      });
  }
}

class VersionCheckerWidget extends StatefulWidget {
  final VersionCheckerManager manager;
  final Function(bool) onUpdateAvaible;
  final Widget Function() onLoading;

  const VersionCheckerWidget({Key key, @required this.manager, this.onUpdateAvaible, this.onLoading}) : super(key: key);

  @override
  _VersionCheckerWidgetState createState() => _VersionCheckerWidgetState();
}

class _VersionCheckerWidgetState extends State<VersionCheckerWidget> {
  @override
  void initState() {
    super.initState();
    widget.manager.checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetStatusHandler(
      manager: widget.manager.widgetStatusManager,
      onDone: (setting) {
        return widget.onUpdateAvaible(widget.manager.checkUpdate.lastResult ?? false);
      },
      onLoading: (setting) {
        return widget.onLoading();
      },
    );
  }
}

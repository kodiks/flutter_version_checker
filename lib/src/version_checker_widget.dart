import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info/package_info.dart';
import 'package:rx_command/rx_command.dart';
import 'package:status_handler/status_handler.dart';
import 'package:upgrader/upgrader.dart';

class VersionCheckerManager with WidgetStatusMixin {
  RxCommand<void, bool> checkUpdateCommand;
  RxCommand<dynamic, dynamic> lastErrorCommand;

  VersionCheckerManager() {
    lastErrorCommand = RxCommand.createSync((error) => error);
    checkUpdateCommand = RxCommand.createAsyncNoParam(() async {
      statusLoad();
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
      })
      ..handleError((error) {
        lastErrorCommand(error);
        statusError();
      });
  }
}

class VersionCheckerWidget extends StatefulWidget {
  final VersionCheckerManager manager;
  final Function(bool) onUpdateAvaible;
  final Widget Function() onLoading;
  final Function(Exception) onError;

  const VersionCheckerWidget({Key key, @required this.manager, @required this.onUpdateAvaible, this.onLoading, this.onError}) : super(key: key);

  @override
  _VersionCheckerWidgetState createState() => _VersionCheckerWidgetState();
}

class _VersionCheckerWidgetState extends State<VersionCheckerWidget> {
  @override
  void initState() {
    super.initState();
    widget.manager.checkUpdateCommand();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetStatusHandler(
      manager: widget.manager.widgetStatusManager,
      onDone: (setting) {
        return widget.onUpdateAvaible(widget.manager.checkUpdateCommand.lastResult ?? false);
      },
      onLoading: (setting) {
        if (widget.onLoading != null) {
          return widget.onLoading();
        } else {
          return Container();
        }
      },
      onError: (setting) {
        if (widget.onError != null) {
          widget.onError(widget.manager.lastErrorCommand.lastResult);
        }
        return Container();
      },
    );
  }
}

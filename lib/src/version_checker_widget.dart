import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info/package_info.dart';
import 'package:rx_command/rx_command.dart';
import 'package:status_handler/status_handler.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version_checker/src/version_info.dart';

class VersionCheckerManager with WidgetStatusMixin {
  RxCommand<void, VersionInfo> checkUpdateCommand;
  RxCommand<dynamic, dynamic> lastErrorCommand;

  VersionCheckerManager() {
    lastErrorCommand = RxCommand.createSync((error) => error);
    checkUpdateCommand = RxCommand.createAsyncNoParam(() async {
      statusLoad();
      //* Get instaled app version
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        //* Android
        final AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
        final versionInfo = VersionInfo(
          updateAvaible: appUpdateInfo.updateAvailable,
          newVersion: appUpdateInfo.availableVersionCode.toString(),
          appId: packageInfo.packageName,
        );

        return Future.value(versionInfo);
      } else {
        //* iOS
        final iTunes = ITunesSearchAPI();

        final results = await iTunes.lookupByBundleId(packageInfo.packageName);

        final storeVersionInfo = ITunesResults.version(results);

        final int storeVesion = int.parse(storeVersionInfo.replaceAll(".", ""));
        final int localVersion = int.parse(packageInfo.version.replaceAll(".", ""));

        final versionInfo = VersionInfo(
          updateAvaible: storeVesion > localVersion,
          newVersion: storeVersionInfo,
          appId: trackId(results),
        );

        return Future.value(versionInfo);
      }
    })
      ..listen((versionInfo) {
        statusDone();
      })
      ..thrownExceptions
      ..listen((error) {
        statusError();
        lastErrorCommand(error);
      });
  }

  String trackId(Map response) {
    String value;
    try {
      value = response['results'][0]['trackId'].toString();
    } catch (e) {
      print('upgrader.ITunesResults.trackId: $e');
    }
    return value;
  }
}

class VersionCheckerWidget extends StatefulWidget {
  final VersionCheckerManager manager;
  final Widget Function(VersionInfo) onUpdateAvaible;
  final Widget Function() onLoading;
  final Widget Function(Exception) onError;

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
        return widget.onUpdateAvaible(widget.manager.checkUpdateCommand.lastResult ?? VersionInfo());
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
          return widget.onError(widget.manager.lastErrorCommand.lastResult);
        } else {
          return Container();
        }
      },
    );
  }
}

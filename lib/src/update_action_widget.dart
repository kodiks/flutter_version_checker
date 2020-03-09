import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:version_checker/src/version_info.dart';

class UpdateActionWidget extends StatelessWidget {
  final VersionInfo versionInfo;
  final String infoText;
  final TextStyle textStyle;
  final String updateButtonText;
  final String exitButonText;

  const UpdateActionWidget({
    Key key,
    @required this.versionInfo,
    this.infoText = "Uygulamanın yeni versiyonu mevcut. Lütfen uygulamayı kullanmak için yeni versiyonu yükleyin.",
    this.textStyle = const TextStyle(
      fontSize: 16,
    ),
    this.updateButtonText = "Güncelle",
    this.exitButonText = "Kapat",
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(infoText),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              OutlineButton(
                child: Text(exitButonText),
                onPressed: () {
                  exit(0);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              OutlineButton(
                child: Text(updateButtonText),
                onPressed: () {
                  StoreRedirect.redirect(androidAppId: versionInfo.appId, iOSAppId: versionInfo.appId);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

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
  final TextStyle updateButtonTextStyle;
  final String exitButonText;
  final TextStyle exitButonTextStyle;
  final EdgeInsets margin;
  const UpdateActionWidget({
    Key key,
    @required this.versionInfo,
    this.infoText = "Uygulamanın yeni versiyonu mevcut.\nLütfen uygulamayı kullanmak için yeni versiyonu yükleyin.",
    this.textStyle = const TextStyle(
      fontSize: 16,
    ),
    this.updateButtonText = "Güncelle",
    this.updateButtonTextStyle = const TextStyle(color: Colors.white),
    this.exitButonText = "Kapat",
    this.exitButonTextStyle,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              infoText,
              style: textStyle,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              OutlineButton(
                child: Text(
                  exitButonText,
                  style: exitButonTextStyle,
                ),
                onPressed: () {
                  exit(0);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              OutlineButton(
                child: Text(updateButtonText, style: updateButtonTextStyle),
                borderSide: BorderSide(color: Colors.blue),
                color: Colors.blue,
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

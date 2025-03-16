import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class Helper {
  Helper._privateConstructor();
  static final Helper _instance = Helper._privateConstructor();

  factory Helper() {
    return _instance;
  }

  double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static void errorAlertAndNavigate(
      BuildContext context, String content, String title) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: content,
      title: title,
      confirmBtnColor: Colors.red,
      confirmBtnText: "Continue",
    );
  }
}

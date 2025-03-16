import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Util {
  static void successAlertAndNavigate(BuildContext context, String title) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: title,
      confirmBtnColor: Colors.green,
      confirmBtnText: "Success",
    ).then((value) {
      Navigator.of(context).pop();
    });
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

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitWave(
            color: Colors.blue,
            size: 50.0,
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

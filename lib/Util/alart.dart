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

  static void successAlertAndGoToPage(
    BuildContext context,
    String title,
    Widget destinationPage,
  ) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: title,
      confirmBtnColor: Colors.green,
      confirmBtnText: "Continue",
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destinationPage,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));

                final fadeAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }

  static void navigateWithFade(BuildContext context, Widget destinationPage) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            destinationPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: Offset(1.0, 0.0), // sağdan gelsin
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
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

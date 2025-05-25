import 'package:envolet_frontend/Auth/login.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static void showSuccessAlertForCardUpdateaAdDelete(
    BuildContext context,
    String message, {
    required VoidCallback onContinue,
  }) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: message,
      confirmBtnText: "Continue",
      confirmBtnColor: const Color(0xFF2D6BFF),
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      textColor: Colors.black54,
      confirmBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 16,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
    Future.delayed(Duration(milliseconds: 100), onContinue);
  }

  static void successAlertAndGoToPage(
    BuildContext context,
    String title,
    Widget destinationPage,
  ) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Success",
      text: title,
      confirmBtnText: "Ok",
      confirmBtnColor: const Color(0xFF2D6BFF), // tam mavi
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.2),
      titleColor: Colors.black,
      textColor: Colors.black54,
      confirmBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 16,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destinationPage,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
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
  }

  static void errorAlertAndNavigate(
      BuildContext context, String content, String title) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: content,
      confirmBtnText: 'Try Again',
      confirmBtnColor: Colors.red,
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      textColor: Colors.black87,
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

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 230),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Are you sure you want to sign out?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    await pref.clear();
                    Navigator.of(context).pop();
                    Util.navigateWithFade(context, LoginPage());
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDeleteAccountDialog(BuildContext context) {
    bool isConfirmed = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 230),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Deleting your account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Are you sure you want to delete your account?\nThis action cannot be undone.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isConfirmed
                            ? () async {
                                await Api.deleteAccount();
                                Navigator.of(context).pop();
                                Util.navigateWithFade(context, LoginPage());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isConfirmed,
                            onChanged: (val) => setState(() {
                              isConfirmed = val ?? false;
                            }),
                          ),
                          const Text("I am sure."),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showSuccessAlert(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: message,
      confirmBtnText: "Continue",
      confirmBtnColor: const Color(0xFF2D6BFF),
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      textColor: Colors.black54,
      confirmBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  static void showTransactionUpdateSuccessBottomSheet(
    BuildContext context, {
    required String category,
    required double amount,
    required DateTime date,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {}, // İç tıklamayı engelle
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C851), // QuickAlert success yeşili
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Transaction Updated!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your expense has been updated!",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _SuccessInfoRow(
                        "Date", DateFormat('dd MMM, yyyy').format(date)),
                    const SizedBox(height: 12),
                    _SuccessInfoRow("Category", category),
                    const SizedBox(height: 12),
                    _SuccessInfoRow(
                        "Amount", "${amount.toString()} $globalCurrency"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void showTransactionSuccessBottomSheet(
    BuildContext context, {
    required String category,
    required double amount,
    required DateTime date,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {}, // İç tıklamayı engelle
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C851), // QuickAlert success yeşili
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Transaction Successful",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your expense has been recorded!",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _SuccessInfoRow(
                        "Date", DateFormat('dd MMM, yyyy').format(date)),
                    const SizedBox(height: 12),
                    _SuccessInfoRow("Category", category),
                    const SizedBox(height: 12),
                    _SuccessInfoRow(
                        "Amount", "${amount.toString()} $globalCurrency"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _SuccessInfoRow(String label, String value,
      {bool isCurrency = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (isCurrency) ...[
              const SizedBox(width: 6),
              Icon(
                currencyIcons[globalCurrency] ?? Icons.attach_money,
                size: 14,
                color: Colors.black87,
              ),
            ]
          ],
        ),
      ],
    );
  }
}

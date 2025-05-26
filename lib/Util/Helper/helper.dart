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
}

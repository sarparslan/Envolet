import 'package:flutter/material.dart';

class Constants {
  Constants._privateConstructor();
  static final Constants _instance = Constants._privateConstructor();

  factory Constants() {
    return _instance;
  }

  //Dark Mode
  Color backgroundColorDark = Color(0xFF1A374D);
  Color articleButtonColorDark = Color(0xFF406882);

  Color headingColorDark = Color(0xFFA1CCD1);
  Color mainContainerColorDark = Color(0xFF6998AB);

  Color enterTextLabelFillColorDark = Color(0xFF406882);
  Color enterTextBorderColorDark = Color(0xFF406882);

  Color unlikedHeartColorDark = Color(0xFF164B60);

  Color containerTextColorDark = Colors.white;
  Color articelTextColorDark = Colors.white;
  Color checkButtonColorDark = Color(0xFF406882);

  Color favoriteWordsColorDark = Color(0xFFB1D0E0);
  Color favoritePageThrashIconColorDark = Colors.white;
  Color favoritePracticeEnterIconColorDark = Colors.white;
  Color bottomBorColorDark = Color(0xFF6998AB);

  Color toggleArtikelColorDark = Color.fromARGB(255, 137, 205, 227);
  Color toggleKeyboardColorDark = Color(0XFf189AB4); //Color(0XFf00AEAE);

  Color toggleArtikelIconColorDark = Colors.white;
  Color toggleKeyboardIconColorDark = Colors.white;
  Color favoriteTextColorDark = Color(0xFFB1D0E0);

  //Light Mode
  Color backgroundColorLight = Color.fromARGB(255, 239, 246, 246);

  Color articleButtonColorLight = Color.fromARGB(255, 137, 187, 202);

  Color articelTextColorLight = Colors.white;

  Color headingColorLight = Color.fromARGB(255, 71, 142, 150);
  Color mainContainerColorLight = Color.fromARGB(255, 204, 229, 237);

  Color enterTextLabelFillColorLight = Color.fromARGB(255, 204, 229, 237);
  Color enterTextBorderColorLight = Color.fromARGB(255, 100, 156, 193);
  Color enterTextColorLight = Color.fromARGB(255, 100, 156, 193);

  Color unlikedHeartColorLight = Color(0xFF6998AB);

  Color containerTextColorLight = Color.fromARGB(255, 71, 142, 150);
  Color checkButtonColorLight = Color.fromARGB(255, 100, 156, 193);

  Color favoriteWordsColorLight = Color.fromARGB(255, 151, 190, 209);
  Color favoritePageThrashIconColorLight = Color.fromARGB(255, 71, 142, 150);
  Color favoritePracticeEnterIconColorLight = Color.fromARGB(255, 71, 142, 150);
  Color bottomBarColorLight = Color.fromARGB(255, 122, 180, 202);

  Color toggleArtikelColorLight = Color.fromARGB(255, 137, 205, 227);
  Color toggleArtikelIconColorLight = Colors.white;

  Color toggleKeyboardColorLight = Color(0XFf189AB4);
  Color toggleKeyboardIconColorLight = Colors.white;

  Color teal = Color(0xFF15CDCA);
  Color green = Color(0xFF4FE0B6);
  Color darkBlue2 = Color(0xFF003B8E);
  Color darkBlue = Color(0xFF1564BF);

  Color mainBlue = Color(0xFF007BA7);

  final darkGradient = LinearGradient(
      colors: <Color>[Color(0XFf189AB4), Color.fromARGB(255, 137, 205, 227)]);

  final whiteGradient =
      LinearGradient(colors: <Color>[Colors.white, Colors.white]);
}

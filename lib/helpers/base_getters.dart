import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app_config.dart';

class AppServices {
  /* Height and Width Factors */

  // get width of the screen
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // get height of the screen
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // used to add space between two vertical objects
  static addHeight(double space) => SizedBox(height: space);

  // used to add space between two horizontal objects
  static addWidth(double space) => SizedBox(width: space);

// to check the screen is android or web
  static bool isSmallScreen(BuildContext context) =>
      getScreenWidth(context) <= 360;

// rupees currency symbol
  static String getCurrencySymbol = "\u{20B9}";

  /* Navigation and routing */
  static pushTo(Widget screen, BuildContext context) =>
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            CupertinoPageTransition(
                primaryRouteAnimation: animation,
                secondaryRouteAnimation: secondaryAnimation,
                linearTransition: true,
                child: child),
      ));

  static pushAndReplace(Widget screen, BuildContext context) =>
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              CupertinoPageTransition(
                  primaryRouteAnimation: animation,
                  secondaryRouteAnimation: secondaryAnimation,
                  linearTransition: true,
                  child: child)));
  // navigate to next screen and remove all the screens behind
  static pushAndRemove(Widget screen, BuildContext context) =>
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    CupertinoPageTransition(
                        primaryRouteAnimation: animation,
                        secondaryRouteAnimation: secondaryAnimation,
                        linearTransition: true,
                        child: child),
          ),
          (route) => false);

  // navigation and routing with fade transition
  static fadeTransitionNavigation(BuildContext context, Widget screen) =>
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionDuration: const Duration(milliseconds: 1100),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child)),
          (route) => false);

  // navigate to the previous screen or previous state
  static popView(BuildContext context) => Navigator.of(context).pop();

  // function to unfocus the keyboard on tap on screen
  static keyboardUnfocus(BuildContext context) =>
      FocusScope.of(context).unfocus();

  /* UI Scale Factor */
  static double scaleFactor(BuildContext context) {
    if (getScreenWidth(context) > AppConfig.screenWidth) {
      return AppConfig.screenWidth / getScreenWidth(context);
    } else {
      return getScreenWidth(context) / AppConfig.screenWidth;
    }
  }

  static showToast(String msg) => Fluttertoast.showToast(
      backgroundColor: AppColors.primaryColor,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_LONG,
      msg: msg);
}

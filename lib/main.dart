import 'package:chatting_app/Screens/splash.dart';
import 'package:chatting_app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarIconBrightness: Brightness.dark,
                      statusBarColor: Colors.transparent)),
              // textButtonTheme: TextButtonThemeData(
              //     style: ButtonStyle(
              //         backgroundColor:
              //             MaterialStateProperty.all(AppColors.primaryColor),
              //         foregroundColor:
              //             MaterialStateProperty.all(AppColors.whiteColor)))
            ),
            home: const SplashScreen()),
        splitScreenMode: false,
        designSize: const Size(AppConfig.screenWidth, AppConfig.screenHeight));
  }
}

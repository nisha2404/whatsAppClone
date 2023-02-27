// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/style_sheet.dart';

class ExpandedButton extends StatelessWidget {
  String btnName;
  double padding, radius;
  Color bgColor, txtColor;
  Function onPress;
  String prefixImg;

  ExpandedButton(
      {Key? key,
      required this.btnName,
      this.padding = 15,
      this.radius = 10,
      this.bgColor = AppColors.primaryColor,
      this.txtColor = AppColors.whiteColor,
      required this.onPress,
      this.prefixImg = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Platform.isAndroid
            ? TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(padding)),
                    backgroundColor: MaterialStateProperty.all(bgColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                        side: BorderSide.none))),
                onPressed: () => onPress(),
                child: Row(
                  children: [
                    prefixImg == ""
                        ? const SizedBox()
                        : Image.asset(
                            prefixImg,
                            height: 22.sp,
                            color: txtColor,
                          ),
                    Expanded(
                      child: Text(btnName,
                          textAlign: TextAlign.center,
                          style: GetTextTheme.sf14_regular.copyWith(
                              fontWeight: FontWeight.w500, color: txtColor)),
                    ),
                  ],
                ))
            : CupertinoButton(
                borderRadius: BorderRadius.circular(radius),
                padding: EdgeInsets.all(padding),
                color: bgColor,
                onPressed: () => onPress(),
                child: Text(
                  btnName,
                  style: GetTextTheme.sf14_regular
                      .copyWith(fontWeight: FontWeight.w500, color: txtColor),
                ),
              ));
  }
}

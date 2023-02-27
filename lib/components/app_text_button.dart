// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  Function onpress;
  String btnName;
  TextStyle? txtStyle;
  Color? btnColor;
  AppTextButton(
      {Key? key,
      required this.onpress,
      required this.btnName,
      this.txtStyle,
      this.btnColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? TextButton(
            style: btnColor == null
                ? null
                : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(btnColor)),
            onPressed: () => onpress(),
            child: Text(btnName, style: txtStyle))
        : CupertinoButton(
            color: btnColor,
            child: Text(btnName, style: txtStyle),
            onPressed: () {});
  }
}

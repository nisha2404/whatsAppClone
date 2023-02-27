// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../helpers/style_sheet.dart';

class TextSpanButton extends StatelessWidget {
  String txt, btnName;
  Function onPress;
  TextSpanButton(
      {Key? key,
      required this.txt,
      required this.btnName,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Text.rich(
          TextSpan(text: txt, style: GetTextTheme.sf14_regular, children: [
        TextSpan(
            text: " $btnName",
            style:
                GetTextTheme.sf14_bold.copyWith(color: AppColors.primaryColor))
      ])),
    );
  }
}

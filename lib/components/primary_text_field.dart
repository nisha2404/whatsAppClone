// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/style_sheet.dart';

class TextFieldPrimary extends StatelessWidget {
  String hint, prefix;
  TextEditingController? controller;
  Function(String)? onchange;
  double verticalpadding, horizontalpadding;
  int maxlines;
  Color prefixColor;
  Color? color;
  double radius;
  TextInputType inputType;
  bool isObsecure;
  InputBorder? border;
  bool isDense, readOnly;

  TextFieldPrimary(
      {Key? key,
      this.hint = "",
      this.controller,
      this.onchange,
      this.prefix = '',
      this.verticalpadding = 15,
      this.horizontalpadding = 20,
      this.maxlines = 1,
      this.prefixColor = AppColors.grey100,
      this.color,
      this.radius = 10,
      this.inputType = TextInputType.text,
      this.isObsecure = false,
      this.border,
      this.isDense = false,
      this.readOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? TextField(
            obscureText: isObsecure,
            keyboardType: inputType,
            onChanged: onchange == null ? null : (value) => onchange!(value),
            maxLines: maxlines,
            controller: controller,
            readOnly: readOnly,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                enabledBorder: border,
                filled: true,
                // fillColor: AppColors.grey50,
                fillColor: color,
                isDense: isDense,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(radius.r)),
                hintText: hint,
                hintStyle: GetTextTheme.sf14_regular
                    .copyWith(color: const Color.fromARGB(188, 154, 154, 154)),
                prefixIcon: prefix == ''
                    ? null
                    : IconButton(
                        onPressed: null,
                        iconSize: 15,
                        icon: Image.asset(
                          prefix,
                          height: 22.sp,
                          color: prefixColor,
                        ),
                      ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: horizontalpadding.w,
                    vertical: verticalpadding.h)),
          )
        : CupertinoTextField(
            readOnly: readOnly,
            onChanged: (value) => onchange!(value),
            maxLines: maxlines,
            controller: controller,
            obscuringCharacter: "*",
            decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(10.r)),
            placeholder: hint,
            placeholderStyle: GetTextTheme.sf14_regular
                .copyWith(color: const Color.fromARGB(188, 154, 154, 154)),
            prefix: prefix == ""
                ? null
                : IconButton(
                    onPressed: null,
                    iconSize: 15,
                    icon: Image.asset(
                      prefix,
                      height: 22.sp,
                      color: prefixColor,
                    ),
                  ),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalpadding.w, vertical: verticalpadding.h),
          );
  }
}

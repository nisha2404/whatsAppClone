// ignore_for_file: must_be_immutable

import 'package:chatting_app/components/primary_text_field.dart';
import 'package:flutter/material.dart';

import '../helpers/style_sheet.dart';

class UnderlineInputBorderTextField extends StatelessWidget {
  String hint;
  TextEditingController? controller;
  TextInputType inputType;
  bool isDense, readOnly;
  double horizontalpadding, verticalpadding;
  int? maxlength;
  Function? ontap;
  UnderlineInputBorderTextField(
      {super.key,
      this.hint = "",
      this.controller,
      this.inputType = TextInputType.text,
      this.isDense = false,
      this.readOnly = false,
      this.horizontalpadding = 2,
      this.verticalpadding = 5,
      this.maxlength,
      this.ontap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryColor))),
      child: TextFieldPrimary(
        ontap: ontap != null ? () => ontap!() : null,
        maxLength: maxlength,
        inputType: inputType,
        controller: controller,
        color: Colors.transparent,
        horizontalpadding: horizontalpadding,
        verticalpadding: verticalpadding,
        isDense: isDense,
        hint: hint,
        readOnly: readOnly,
      ),
    );
  }
}

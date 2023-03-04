// ignore_for_file: use_build_context_synchronously

import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateuserAboutDialog extends StatelessWidget {
  UpdateuserAboutDialog({super.key});

  final TextEditingController _about = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Update About", style: GetTextTheme.sf18_bold),
            AppServices.addHeight(10.h),
            UnderlineInputBorderTextField(
              controller: _about,
            ),
            AppServices.addHeight(20.sp),
            Row(
              children: [
                ExpandedButton(
                    btnName: "Cancel",
                    onPress: () => AppServices.popView(context),
                    bgColor: AppColors.blackColor.withOpacity(0.25),
                    txtColor: AppColors.blackColor),
                AppServices.addWidth(10.w),
                ExpandedButton(
                    btnName: "Update", onPress: () => updateUserAbout(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  updateUserAbout(BuildContext context) async {
    if (_about.text.isNotEmpty) {
      final path = database.ref("users/${auth.currentUser!.uid}");
      await path.update({"about": _about.text});
      AppServices.popView(context);
    }
  }
}

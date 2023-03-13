// ignore_for_file: use_build_context_synchronously

import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../controllers/app_data_controller.dart';
import '../../../../../controllers/firebase_controller.dart';
import '../../../../../models/app_models.dart';

class UpdateUsernameDialog extends StatelessWidget {
  UpdateUsernameDialog({super.key});

  final TextEditingController _username = TextEditingController();

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
            const Text("Update username", style: GetTextTheme.sf18_bold),
            AppServices.addHeight(10.h),
            UnderlineInputBorderTextField(
              controller: _username,
              hint: "Enter new username",
              maxlength: 20,
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
                    btnName: "Update", onPress: () => updateUsername(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  updateUsername(BuildContext context) async {
    if (_username.text.isNotEmpty) {
      final path = database.ref("users/${auth.currentUser!.uid}");
      await path.update({"userName": _username.text});
      await path.get().then((value) {
        final db = Provider.of<AppDataController>(context, listen: false);
        db.setCurrentUser(UserModel.fromUser(
            value.value as Map<Object?, Object?>, value.key.toString()));
      });
      AppServices.popView(context);
    }
  }
}

// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UpdateuserAboutDialog extends StatefulWidget {
  String about;
  UpdateuserAboutDialog({super.key, required this.about});

  @override
  State<UpdateuserAboutDialog> createState() => _UpdateuserAboutDialogState();
}

class _UpdateuserAboutDialogState extends State<UpdateuserAboutDialog> {
  TextEditingController about = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      about.text = widget.about;
    });
  }

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
              controller: about,
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
    if (about.text.isNotEmpty) {
      final path = database.ref("users/${auth.currentUser!.uid}");
      await path.update({"about": about.text});
      await path.get().then((value) {
        final db = Provider.of<AppDataController>(context, listen: false);
        db.setCurrentUser(UserModel.fromUser(
            value.value as Map<Object?, Object?>, value.key.toString()));
      });
      AppServices.popView(context);
    }
  }
}

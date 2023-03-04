import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controllers/firebase_controller.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';
import '../../../../models/app_models.dart';

class TextMessageTile extends StatelessWidget {
  ChatModel chat;
  AppDataController controller;
  TextMessageTile({super.key, required this.chat, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: FirebaseController().isSender(chat)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          shape: RoundedRectangleBorder(
              borderRadius: FirebaseController().isSender(chat)
                  ? BorderRadius.circular(10.r)
                      .copyWith(bottomRight: const Radius.circular(0))
                  : BorderRadius.circular(10.r)
                      .copyWith(bottomLeft: const Radius.circular(0))),
          color: FirebaseController().isSender(chat)
              ? AppColors.orange40
              : AppColors.whiteColor,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: AppServices.getScreenWidth(context) - 80.w),
            padding: const EdgeInsets.all(10.0),
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: AppServices.getScreenWidth(context) - 80.w),
                  child: Text(chat.msg, style: GetTextTheme.sf16_regular),
                ),
                AppServices.addWidth(10.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(controller.getTimeFormat(chat.sendAt),
                        style: GetTextTheme.sf10_regular),
                    AppServices.addWidth(5),
                    FirebaseController().isSender(chat)
                        ? Icon(Icons.done_all,
                            size: 18.sp,
                            color: chat.isSeen
                                ? AppColors.blueColor
                                : AppColors.grey150)
                        : const SizedBox()
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

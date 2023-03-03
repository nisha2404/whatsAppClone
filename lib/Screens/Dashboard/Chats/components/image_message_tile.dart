// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/components/shimmers/chat_image_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controllers/firebase_controller.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';

class ImageMessageTile extends StatelessWidget {
  ChatModel chat;
  AppDataController controller;
  ImageMessageTile({super.key, required this.chat, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FirebaseController().isSender(chat)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.sp),
            height: 200.sp,
            width: 150.sp,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(15.r)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: chat.msgType == "imageWithText"
                    ? chat.msg.split("__").first
                    : chat.msg,
                placeholder: (context, url) => ChatImageShimmer(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
              decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15.r)
                      .copyWith(topRight: const Radius.circular(0))),
              child: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}

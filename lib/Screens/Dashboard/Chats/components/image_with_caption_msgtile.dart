// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/components/shimmers/chat_image_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/firebase_controller.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';

class ImageWithCaptionMsgTile extends StatelessWidget {
  ChatModel chat;
  AppDataController controller;
  bool isShowDelete;
  Function? onDelete;
  ImageWithCaptionMsgTile(
      {super.key,
      required this.chat,
      required this.controller,
      this.isShowDelete = false,
      this.onDelete});

  final FirebaseController _controller = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: _controller.isSender(chat)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.only(top: 5.sp),
              height: 320.sp,
              width: 220.sp,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15.r)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: chat.msg.split("__").first,
                  placeholder: (context, url) => ChatImageShimmer(),
                ),
              ),
            ),
            isShowDelete
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    child: IconButton(
                        onPressed: () {
                          onDelete!();
                        },
                        icon: const Icon(Icons.delete)))
                : const SizedBox()
          ],
        ),
        Positioned(
            bottom: 0,
            right: _controller.isSender(chat) ? 0 : null,
            left: _controller.isSender(chat) ? null : 0,
            child: Row(
              mainAxisAlignment: FirebaseController().isSender(chat)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 2.sp),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          // top: Radius.circular(15.r),
                          bottom: Radius.circular(15.r))),
                  color: FirebaseController().isSender(chat)
                      ? AppColors.orange40
                      : AppColors.whiteColor,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    constraints: BoxConstraints(maxWidth: 220.sp),
                    width: 220.sp,
                    padding: EdgeInsets.all(10.sp),
                    child: Column(
                      crossAxisAlignment: FirebaseController().isSender(chat)
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(chat.msg.split("__").last,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GetTextTheme.sf16_regular),
                        AppServices.addWidth(10.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: FirebaseController().isSender(chat)
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Text(DateFormat("hh:mm a").format(chat.sendAt),
                                style: GetTextTheme.sf10_regular),
                            AppServices.addWidth(5.w),
                            FirebaseController().isSender(chat)
                                ? chat.isDelivered == false
                                    ? Icon(Icons.done,
                                        size: 18.sp, color: AppColors.grey150)
                                    : Icon(Icons.done_all,
                                        size: 18.sp,
                                        color: chat.isSeen
                                            ? AppColors.primaryColor
                                            : AppColors.grey150)
                                : const SizedBox()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

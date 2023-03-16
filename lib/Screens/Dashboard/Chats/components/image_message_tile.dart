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
  bool isShowDelete;
  Function? onDelete;
  bool isuserActive;
  ImageMessageTile(
      {super.key,
      required this.chat,
      required this.controller,
      this.isShowDelete = false,
      this.onDelete,
      this.isuserActive = false});

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
                  imageUrl: chat.msg,
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 8.sp),
            decoration: BoxDecoration(
                color: _controller.isSender(chat)
                    ? AppColors.orange40
                    : AppColors.whiteColor,
                borderRadius: _controller.isSender(chat)
                    ? BorderRadius.circular(15.r)
                        .copyWith(topRight: const Radius.circular(0))
                    : BorderRadius.circular(15.r)
                        .copyWith(topLeft: const Radius.circular(0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(controller.getTimeFormat(chat.sendAt),
                    style: GetTextTheme.sf10_regular),
                AppServices.addWidth(5),
                _controller.isSender(chat)
                    ? isuserActive == false
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
          ),
        ),
      ],
    );
  }
}

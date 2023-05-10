// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controllers/firebase_controller.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';
import '../../../../models/app_models.dart';

class TextMessageTile extends StatelessWidget {
  UserModel? user;
  ChatModel chat;
  AppDataController controller;
  bool isSelected;
  TextMessageTile(
      {super.key,
      required this.chat,
      this.user,
      required this.controller,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.sp),
      padding: EdgeInsets.symmetric(horizontal: 5.sp),
      decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.15)
              : Colors.transparent),
      child: chat.replyAt != ""
          ? Row(
              mainAxisAlignment: FirebaseController().isSender(chat.sender)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: FirebaseController().isSender(chat.sender)
                          ? BorderRadius.circular(10.r)
                              .copyWith(bottomRight: const Radius.circular(0))
                          : BorderRadius.circular(10.r)
                              .copyWith(bottomLeft: const Radius.circular(0))),
                  color: FirebaseController().isSender(chat.sender)
                      ? AppColors.orange40
                      : AppColors.whiteColor,
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: AppServices.getScreenWidth(context) - 80.w),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          constraints: BoxConstraints(
                              minWidth:
                                  AppServices.getScreenWidth(context) - 95.w,
                              maxWidth:
                                  AppServices.getScreenWidth(context) - 80.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: AppColors.orange60.withOpacity(0.1)),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    FirebaseController()
                                            .isSender(chat.replyAt.senderId)
                                        ? "You"
                                        : user!.phoneNumber,
                                    style: GetTextTheme.sf14_bold.copyWith(
                                        color: AppColors.primaryColor),
                                  ),
                                  Text(
                                      chat.replyAt.type == "image"
                                          ? "📷 Photo"
                                          : chat.replyAt.type == "imageWithText"
                                              ? chat.replyAt.msg
                                                  .toString()
                                                  .split("__")
                                                  .last
                                              : chat.replyAt.msg,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GetTextTheme.sf14_regular
                                          .copyWith(color: AppColors.grey150)),
                                  chat.replyAt.type == "image"
                                      ? CachedNetworkImage(
                                          imageUrl: chat.replyAt.msg,
                                          fit: BoxFit.cover)
                                      : chat.replyAt.type == "imageWithText"
                                          ? CachedNetworkImage(
                                              imageUrl: chat.replyAt.msg
                                                  .toString()
                                                  .split("__")
                                                  .first,
                                              fit: BoxFit.cover)
                                          : const SizedBox()
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppServices.addHeight(10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppServices.addWidth(5.w),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          AppServices.getScreenWidth(context) -
                                              80.w),
                                  child: Text(chat.msg,
                                      style: GetTextTheme.sf16_regular),
                                ),
                              ],
                            ),
                            AppServices.addWidth(10.w),
                            Padding(
                              padding: EdgeInsets.only(top: 2.sp),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(controller.getTimeFormat(chat.sendAt),
                                      style: GetTextTheme.sf10_regular),
                                  AppServices.addWidth(5),
                                  // chat.status == MessageStatus.deleteForMe ||
                                  //         chat.status == MessageStatus.deleteForEveryone
                                  //     ? const SizedBox()
                                  //     : (FirebaseController().isSender(chat)sender         ? AppServices.getMessageStatusIcon(chat)
                                  //         : const SizedBox())

                                  FirebaseController().isSender(chat.sender)
                                      ? (AppServices.getMessageStatusIcon(chat))
                                      : const SizedBox()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: FirebaseController().isSender(chat.sender)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: FirebaseController().isSender(chat.sender)
                          ? BorderRadius.circular(10.r)
                              .copyWith(bottomRight: const Radius.circular(0))
                          : BorderRadius.circular(10.r)
                              .copyWith(bottomLeft: const Radius.circular(0))),
                  color: FirebaseController().isSender(chat.sender)
                      ? AppColors.orange40
                      : AppColors.whiteColor,
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: AppServices.getScreenWidth(context) - 80.w),
                    padding: const EdgeInsets.all(10.0),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppServices.addWidth(5.w),
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      AppServices.getScreenWidth(context) -
                                          80.w),
                              child: Text(chat.msg,
                                  style: GetTextTheme.sf16_regular),
                            ),
                          ],
                        ),
                        AppServices.addWidth(10.w),
                        Padding(
                          padding: EdgeInsets.only(top: 2.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(controller.getTimeFormat(chat.sendAt),
                                  style: GetTextTheme.sf10_regular),
                              AppServices.addWidth(5),
                              // chat.status == MessageStatus.deleteForMe ||
                              //         chat.status == MessageStatus.deleteForEveryone
                              //     ? const SizedBox()
                              //     : (FirebaseController().isSender(chat)      ? AppServices.getMessageStatusIcon(chat)
                              //         : const SizedBox())

                              FirebaseController().isSender(chat.sender)
                                  ? (AppServices.getMessageStatusIcon(chat))
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

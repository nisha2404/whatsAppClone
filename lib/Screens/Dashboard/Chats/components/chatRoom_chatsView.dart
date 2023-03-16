// ignore_for_file: must_be_immutable

import 'package:chatting_app/Screens/Dashboard/Chats/components/image_with_caption_msgtile.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/text_message_tile.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';
import 'image_message_tile.dart';

class ChatRoomChatsView extends StatelessWidget {
  ScrollController controller;
  AppDataController db;
  List<ChatModel> chats;
  Function onLongPress;
  UserModel user;
  ChatRoomChatsView(
      {super.key,
      required this.controller,
      required this.db,
      required this.chats,
      required this.onLongPress,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.sp),
        child: ListView.separated(
          controller: controller,
          padding: EdgeInsets.symmetric(horizontal: 5.sp),
          itemCount: chats.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            bool isShowDateCard = (i == 0) ||
                ((i == chats.length - 1) &&
                    (chats[i].sendAt.day > chats[i - 1].sendAt.day)) ||
                (chats[i].sendAt.day > chats[i - 1].sendAt.day &&
                    chats[i].sendAt.day <= chats[i + 1].sendAt.day);
            return Column(
              children: [
                isShowDateCard
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 5.sp),
                        margin: EdgeInsets.symmetric(vertical: 10.sp),
                        decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Text(DateFormat.yMMMd().format(chats[i].sendAt)))
                    : const SizedBox(),
                chats[i].msgType == "image"
                    ? GestureDetector(
                        onLongPress: () => {onLongPress()},
                        child: ImageMessageTile(
                            chat: chats[i],
                            controller: db,
                            isuserActive: user.isActive),
                      )
                    : chats[i].msgType == "imageWithText"
                        ? ImageWithCaptionMsgTile(
                            chat: chats[i],
                            controller: db,
                            isuserActive: user.isActive)
                        : TextMessageTile(
                            chat: chats[i],
                            controller: db,
                            isuserActive: user.isActive)
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              AppServices.addHeight(5.h),
        ),
      )),
    );
  }
}

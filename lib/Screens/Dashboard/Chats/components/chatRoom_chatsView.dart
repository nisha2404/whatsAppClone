// ignore_for_file: must_be_immutable

import 'package:chatting_app/Screens/Dashboard/Chats/components/image_with_caption_msgtile.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/text_message_tile.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/firebase_controller.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';
import 'image_message_tile.dart';

class ChatRoomChatsView extends StatelessWidget {
  dynamic chatRoom;
  ScrollController controller;
  // AppDataController db;
  // List<ChatModel> chats;
  // Function onLongPress;
  ChatRoomChatsView(
      {super.key, required this.chatRoom, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.sp),
        child: StreamBuilder<DatabaseEvent>(
            stream:
                database.ref("chatRoom/${chatRoom.chatroomId}/chats").onValue,
            builder: (context, snapshot) {
              List<ChatModel> chats = snapshot.data!.snapshot.children
                  .map((e) => ChatModel.fromChat(
                      e.value as Map<Object?, Object?>, e.key.toString()))
                  .toList();
              return ListView.separated(
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
                              child: Text(
                                  DateFormat.yMMMd().format(chats[i].sendAt)))
                          : const SizedBox(),
                      chats[i].msgType == "image"
                          ? GestureDetector(
                              onLongPress: () => {},
                              child: ImageMessageTile(
                                  chat: chats[i],
                                  controller: AppDataController()),
                            )
                          : chats[i].msgType == "imageWithText"
                              ? ImageWithCaptionMsgTile(
                                  chat: chats[i],
                                  controller: AppDataController())
                              : TextMessageTile(
                                  chat: chats[i],
                                  controller: AppDataController())
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    AppServices.addHeight(5.h),
              );
            }),
      )),
    );
  }
}

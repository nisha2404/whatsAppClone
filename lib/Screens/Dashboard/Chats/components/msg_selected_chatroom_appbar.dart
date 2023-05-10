// ignore_for_file: file_names

import 'package:chatting_app/Screens/Dashboard/Chats/components/pop_ups/delete_for_everyone_dialog.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/pop_ups/delete_for_me_dialog.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../helpers/style_sheet.dart';

dynamic msgSelectedChatRoomAppBar(BuildContext context,
    List<ChatModel> selectedChats, Function onBackPressed, String chatRoomId) {
  return AppBar(
    titleSpacing: 0,
    elevation: 0,
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.whiteColor,
    systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    leading: IconButton(
        onPressed: () => {onBackPressed()}, icon: const Icon(Icons.arrow_back)),
    title: Text(selectedChats.length.toString(), style: GetTextTheme.sf16_bold),
    actions: [
      IconButton(
          onPressed: () {}, splashRadius: 20.r, icon: const Icon(Icons.star)),
      IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => selectedChats.length <= 4 &&
                        selectedChats.every((element) =>
                            element.sender == auth.currentUser!.uid) &&
                        selectedChats.every((element) =>
                            DateTime.now()
                                .difference(DateTime.fromMillisecondsSinceEpoch(
                                    element.sendAt.millisecondsSinceEpoch))
                                .inMinutes <
                            5)
                    ? DeleteForEveryoneDialog(
                        selectedChats: selectedChats, chatRoomId: chatRoomId)
                    : DeleteForMeDialog(
                        selectedChats: selectedChats, chatRoomId: chatRoomId));
          },
          splashRadius: 20.r,
          icon: const Icon(Icons.delete)),
      IconButton(
          onPressed: () {}, splashRadius: 20.r, icon: const Icon(Icons.copy)),
      IconButton(
          onPressed: () {},
          splashRadius: 20.r,
          icon: Image.asset(
            AppIcons.forwardIcon,
            color: AppColors.whiteColor,
            height: 22.sp,
          ))
    ],
  );
}

// ignore_for_file: use_build_context_synchronously

import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:chatting_app/services/chatroom_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatViewTab extends StatefulWidget {
  const ChatViewTab({super.key});

  @override
  State<ChatViewTab> createState() => _ChatViewTabState();
}

class _ChatViewTabState extends State<ChatViewTab> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = Provider.of<ChatroomHandler>(context);
    final chatroomList = services.getAllChatrooms
        .where((element) =>
            element.members.any((mmber) => mmber == auth.currentUser!.uid))
        .toList();
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, i) => ListTile(
            onTap: () => AppServices.pushTo(
                ChatroomView(
                    targetUser: chatroomList[i].members.firstWhere(
                        (element) => element != auth.currentUser!.uid)),
                context),
            title: Text((chatroomList[i].targetUser as UserModel).userName),
            subtitle: Text(chatroomList[i].roomLastMsg)),
        separatorBuilder: (context, i) => AppServices.addHeight(5.h),
        itemCount: chatroomList.length);
  }
}

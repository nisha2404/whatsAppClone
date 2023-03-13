import 'dart:async';

import 'package:chatting_app/components/primary_text_field.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:chatting_app/services/chatroom_handler.dart';
import 'package:chatting_app/services/stream_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../services/functions.dart';

class ChatroomView extends StatefulWidget {
  String targetUser;
  ChatroomView({super.key, required this.targetUser});

  @override
  State<ChatroomView> createState() => _ChatroomViewState();
}

class _ChatroomViewState extends State<ChatroomView> {
  dynamic _chatroom;
  late StreamSubscription<DatabaseEvent> _subscription;
  late StreamSubscription<DatabaseEvent> _updateSubscription;
  final msgController = TextEditingController();
  String text = "";
  @override
  void initState() {
    super.initState();
    initialize();

    final path = database
        .ref("Chatrooms/${_chatroom != null ? _chatroom.roomId : ''}/chats");
    _subscription = path.onChildAdded.listen((event) {
      StreamSubscriptionHandler.onMsgadded(event, _chatroom.roomId, context);
    });

    _updateSubscription = path.onChildChanged.listen((event) {
      StreamSubscriptionHandler.onMsgUpdated(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _updateSubscription.cancel();
  }

  initialize() {
    final services = Provider.of<ChatroomHandler>(context, listen: false);
    services.resetChatroom();
    var room = HexChatFunctions.isChatroomAvailable(widget.targetUser, context);
    if (room.isNotEmpty) {
      setState(() {
        _chatroom = room.first;
      });
    } else {
      null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = Provider.of<ChatroomHandler>(context);
    final msgList = services.getMsgs;
    return Scaffold(
      appBar: AppBar(
        leading: const CircleAvatar(
            backgroundImage: AssetImage(AppImages.avatarPlaceholder)),
        title: const Text("username", style: GetTextTheme.sf16_bold),
      ),
      body: SafeArea(
          child: ListView.separated(
              padding: EdgeInsets.all(15.sp),
              shrinkWrap: true,
              itemBuilder: (context, i) => Column(
                    crossAxisAlignment:
                        HexChatFunctions.getMsgSide(msgList[i].senderid),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: HexChatFunctions.createMsgShape(
                                msgList[i].senderid),
                            color: const Color.fromARGB(255, 129, 204, 255)
                                .withOpacity(0.4)),
                        child: Text(msgList[i].msg,
                            style: GetTextTheme.sf16_medium),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            HexChatFunctions.getMsgTime(msgList[i].sentOn),
                            style: GetTextTheme.sf12_regular,
                          ),
                          Icon(Icons.done_all,
                              size: 15,
                              color: msgList[i].isSeen
                                  ? AppColors.blueColor
                                  : AppColors.blackColor)
                        ],
                      )
                    ],
                  ),
              separatorBuilder: (context, i) => AppServices.addHeight(5),
              itemCount: services.getMsgs.length)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
            .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 10),
        child: Row(
          children: [
            Expanded(
                child: SizedBox(
                    child: TextFieldPrimary(
              onchange: (value) => setState(() => text = value),
              controller: msgController,
            ))),
            text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      services.sendMsg(msgController.text.trim(),
                          widget.targetUser, context);
                      msgController.clear();
                    },
                    icon: const Icon(Icons.send, color: AppColors.primaryColor))
                : IconButton(onPressed: () {}, icon: const Icon(Icons.mic))
          ],
        ),
      ),
    );
  }
}

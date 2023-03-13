import 'package:chatting_app/services/chatroom_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../controllers/firebase_controller.dart';

class HexChatFunctions {
  static String getMsgTime(String time) {
    final currentTime = DateTime.now();
    final msgTime = DateTime.parse(time);
    if (currentTime.difference(msgTime).inMinutes >= 0 &&
        currentTime.difference(msgTime).inMinutes < 60) {
      return "${currentTime.difference(msgTime).inMinutes} min ago";
    } else {
      return "na";
    }
  }

  static CrossAxisAlignment getMsgSide(String senderId) {
    if (senderId == auth.currentUser!.uid) {
      return CrossAxisAlignment.end;
    } else {
      return CrossAxisAlignment.start;
    }
  }

  static BorderRadiusGeometry createMsgShape(String senderId) {
    if (senderId == auth.currentUser!.uid) {
      return BorderRadius.circular(20.r)
          .copyWith(bottomRight: const Radius.circular(0));
    } else {
      return BorderRadius.circular(20.r)
          .copyWith(bottomLeft: const Radius.circular(0));
    }
  }

  static readMsg(String roomId, BuildContext context) async {
    final path = database.ref("Chatrooms/$roomId/chats");
    final snapshot = await path.get();
    if (snapshot.exists) {
      final lastmsg = snapshot.children.last.value as Map<Object?, Object?>;
      print(lastmsg['senderId'].toString());
      bool isSentByMe = lastmsg['senderId'].toString() == auth.currentUser!.uid;
      if (isSentByMe) {
        null;
      } else {
        final services = Provider.of<ChatroomHandler>(context, listen: false);
        var data = services.getMsgs
            .where((element) => element.isSeen == false)
            .toList()
            .map((e) => e.msgId)
            .toList();
        for (var msgId in data) {
          final msgpath = database.ref("Chatrooms/$roomId/chats/$msgId");
          await msgpath.update({"isSeen": true});
        }
      }
    }
  }

  static List<ChatroomsClass> isChatroomAvailable(
      String targetId, BuildContext context) {
    final services = Provider.of<ChatroomHandler>(context, listen: false);
    print(services.getAllChatrooms.length);
    List<ChatroomsClass> availableRooms = [];
    for (var room in services.getAllChatrooms) {
      List<String> membersList = room.members;
      if (membersList.any((element) => element == targetId) &&
          membersList.any((element) => element == auth.currentUser!.uid)) {
        print(room);
        availableRooms.add(room);
      } else {
        print("Nothing found");
        null;
      }
    }
    return availableRooms;
  }
}

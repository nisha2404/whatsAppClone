import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:chatting_app/services/chatroom_handler.dart';
import 'package:chatting_app/services/functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreamSubscriptionHandler {
  static onChatroomAdded(DatabaseEvent event, BuildContext context) async {
    final value = event.snapshot.value as Map<Object?, Object?>;
    final members =
        (value['members'] as List).map((e) => e.toString()).toList();
    final userPath = database.ref(
        "users/${members.firstWhere((element) => element != auth.currentUser!.uid)}");
    final services = Provider.of<ChatroomHandler>(context, listen: false);
    final chatrooms = services.getAllChatrooms;
    final msgPath =
        database.ref("Chatrooms/${event.snapshot.key.toString()}/chats");

    if (chatrooms
        .any((element) => element.roomId == event.snapshot.key.toString())) {
      null;
    } else {
      final memberSnapshot = await userPath.get();
      services.addNewChatroom(ChatroomsClass.fromChatrooms(
          event.snapshot.value as Map<Object?, Object?>,
          event.snapshot.key.toString(),
          UserModel.fromUser(memberSnapshot.value as Map<Object?, Object?>,
              memberSnapshot.key.toString())));

      if (services.getMsgBody != null || services.getMsgBody.isNotEmpty) {
        final chatroompath2 = database
            .ref("Chatrooms/${event.snapshot.key.toString()}/chats")
            .push();
        await chatroompath2.set(services.getMsgBody);
      } else {
        null;
      }
      final snaps = await msgPath.get();
      var lastMsg = snaps.children.last;
      services.setMyLastMsg(
          event.snapshot.key.toString(),
          ChatsClass.fromChat(
              lastMsg.value as Map<Object?, Object?>, lastMsg.key.toString()));
    }
  }

  static onMsgadded(DatabaseEvent event, String roomId, BuildContext context) {
    final services = Provider.of<ChatroomHandler>(context, listen: false);
    var msg = ChatsClass.fromChat(event.snapshot.value as Map<Object?, Object?>,
        event.snapshot.key.toString());
    HexChatFunctions.readMsg(roomId, context);
    print(msg.msg);
    services.addNewMsg(msg);
    services.setMyLastMsg(roomId, msg);
  }

  static onMsgUpdated(BuildContext context) {
    final services = Provider.of<ChatroomHandler>(context, listen: false);
    services.updatemsg();
  }
}

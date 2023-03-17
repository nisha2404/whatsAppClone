import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

dynamic currentChatroomId;

class ChatHandler {
  onGroupMsgSend(
      BuildContext context, DatabaseEvent event, String chatRoomId) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final msg = ChatModel.fromChat(
        event.snapshot.value as Map<Object?, Object?>,
        event.snapshot.key.toString());
    // FirebaseController().msgIsSeen(context, chatRoomId);
    db.addChat(msg);
    db.setLastMsg(chatRoomId, msg);
  }

  // event handler or event listener for a new message add on the database.
  onMsgSend(BuildContext context, DatabaseEvent event, String chatRoomId,
      UserModel targetUser) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final msg = ChatModel.fromChat(
        event.snapshot.value as Map<Object?, Object?>,
        event.snapshot.key.toString());
    FirebaseController().msgIsSeen(context, chatRoomId);
    db.addChat(msg);
    db.setLastMsg(chatRoomId, msg);
    if (targetUser.isActive) {
      await database
          .ref("chatRoom/$chatRoomId/chats/${event.snapshot.key}")
          .update({"isDelivered": true});
      db.updateChatIsDelivered();
    }
  }

// event listener to get the updates of change in any message on database.
  static onMsgUpdated(BuildContext context) {
    final services = Provider.of<AppDataController>(context, listen: false);
    services.updateChatIsSeen();
  }

// event listener to get the chatrooms after adding a new chatRoom on database.
  onChatRoomAdded(BuildContext context, DatabaseEvent event) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.setLoader(true);
    final value = event.snapshot.value as Map<Object?, Object?>;
    final members =
        (value['members'] as List).map((e) => e.toString()).toList();
    final targetUserId =
        members.firstWhere((element) => element != auth.currentUser!.uid);
    final chatRoom = db.getAllChatRooms;

    final userpath = database.ref("users/$targetUserId");
    final chatPath = database.ref("chatRoom/${event.snapshot.key}/chats");

    if (chatRoom.any((element) => element.chatroomId == event.snapshot.key)) {
      null;
      db.setLoader(false);
    } else {
      if (db.getMsg != null || db.getMsg.isNotEmpty) {
        final chatroompath2 =
            database.ref("chatRoom/${event.snapshot.key}/chats").push();
        await chatroompath2.set(db.getMsg);
        db.setTempMsg({});
      } else {
        null;
      }

      final user = await userpath.get();
      final msgs = await chatPath.get();

      if ((user.value as Map<Object?, Object?>)['isActive'] == true) {
        var messages = msgs.children
            .where((element) =>
                (element.value as Map<Object?, Object?>)['isDelivered'] ==
                false)
            .toList();
        for (var msg in messages) {
          final path =
              database.ref("chatRoom/${event.snapshot.key}/chats/${msg.key}");
          await path.update({"isDelivered": true});
        }
      }

      db.addChatRoom(ChatRoomModel.fromChatrooms(
          value,
          event.snapshot.key.toString(),
          msgs.children.isEmpty
              ? null
              : ChatModel.fromChat(
                  msgs.children.last.value as Map<Object?, Object?>,
                  msgs.children.last.key.toString()),
          UserModel.fromUser(
              user.value as Map<Object?, Object?>, user.key.toString())));

      msgs.children.isEmpty
          ? null
          : db.addChat(ChatModel.fromChat(
              msgs.children.last.value as Map<Object?, Object?>,
              msgs.children.last.key.toString()));
      db.setLoader(false);
    }
  }
}

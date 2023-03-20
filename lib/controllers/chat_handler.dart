// ignore_for_file: use_build_context_synchronously

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
    db.addChat(msg);
    db.setLastMsg(chatRoomId, msg);
    final msgStatus =
        (event.snapshot.value as Map<Object?, Object?>)['status'].toString();
    if (targetUser.isActive) {
      if (msgStatus == MessageStatus.sent.name) {
        await database
            .ref("chatRoom/$chatRoomId/chats/${event.snapshot.key}")
            .update({"status": MessageStatus.delivered.name});
        db.updateChatIsDelivered();
      }
    }
    FirebaseController().msgIsSeen(context, chatRoomId);
  }

// event listener to get the updates of change in any message on database.
  static onMsgUpdated(BuildContext context, DatabaseEvent event) {
    final msgStatus =
        (event.snapshot.value as Map<Object?, Object?>)['status'].toString();
    if (msgStatus == MessageStatus.seen.name) {
      final services = Provider.of<AppDataController>(context, listen: false);
      services.updateChatIsSeen();
    }
  }

// event listener to get the chatrooms after adding a new chatRoom on database.
  onChatRoomAdded(BuildContext context, DatabaseEvent event) async {
    final db = Provider.of<AppDataController>(context, listen: false);

    final value = event.snapshot.value as Map<Object?, Object?>;
    final members = (value['members'] as List);
    final targetUserId =
        members.firstWhere((element) => element != auth.currentUser!.uid);
    final chatRoom = db.getAllChatRooms;

    final userpath = database.ref("users/$targetUserId");
    final chatPath = database.ref("chatRoom/${event.snapshot.key}/chats");

    if (chatRoom.any(
        (element) => element.chatroomId == event.snapshot.key.toString())) {
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

      db.setLoader(false);
    }
  }

// function to set data in provider on change in any value in chatRoom.
  setData(DatabaseEvent event, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    if (event.snapshot.exists) {
      var roomId = event.snapshot.key;
      bool isRoomAvailable = db.getAllChatRooms
          .any((element) => element.chatroomId == event.snapshot.key);

      if (isRoomAvailable) {
        final path = database.ref("chatRoom/$roomId/chats");
        final chats = await path.get();
        db.setLastMsg(
            roomId.toString(),
            ChatModel.fromChat(
                chats.children.last.value as Map<Object?, Object?>,
                chats.children.last.key.toString()));
        int unreadChats = chats.children
            .where((element) =>
                (element.value as Map<Object?, Object?>)['status'].toString() ==
                MessageStatus.delivered.name)
            .toList()
            .length;
        db.setUnradMessages(roomId.toString(), unreadChats);
      } else {
        null;
      }
    }
  }

// function to update user data in provider on change in any value in users database.
  setUserData(DatabaseEvent event, BuildContext context) async {
    final userId = event.snapshot.key.toString();
    final path = database.ref("users/$userId");
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatRooms = db.getAllChatRooms.map((e) => e.userdata).toList();
    final isUpdatable = chatRooms
        .where((element) => element.uid == event.snapshot.key.toString())
        .toList();
    if (isUpdatable.isEmpty) return;
    final user = await path.get();
    final index = db.getAllChatRooms
        .indexWhere((element) => element.userdata == isUpdatable.first);
    db.updateUser(
        index,
        (user.value as Map<Object?, Object?>)['isActive'].toString() == "true"
            ? true
            : false,
        int.parse(
            (user.value as Map<Object?, Object?>)['lastSeen'].toString()));
  }
}

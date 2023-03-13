import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/services/functions.dart';
import 'package:flutter/material.dart';

class ChatroomHandler extends ChangeNotifier {
  final chatroomPath = database.ref("Chatrooms");

  Map<String, dynamic> tempMsgBody = {};
  Map<String, dynamic> get getMsgBody => tempMsgBody;
  setTempMsg(Map<String, dynamic> body) {
    tempMsgBody = body;
    notifyListeners();
  }
  /*Model handler 
  chatroom Id
  is Group
  members
  chats
  */

  List<ChatroomsClass> _chatrooms = [];
  List<ChatroomsClass> get getAllChatrooms => _chatrooms;
  setChatroomsList(List<ChatroomsClass> rooms) {
    _chatrooms = rooms;
    notifyListeners();
  }

  addNewChatroom(ChatroomsClass room) {
    _chatrooms.add(room);
    notifyListeners();
  }

  /// Chat msg
  ///
  /// msg
  /// senderId
  /// sent on
  /// is Seen
  /// msgType

  List<ChatsClass> _msg = [];
  List<ChatsClass> get getMsgs => _msg;
  setMsgList(List<ChatsClass> msgs) {
    _msg = msgs;
    notifyListeners();
  }

  addNewMsg(ChatsClass newmsg) {
    _msg.add(newmsg);
    notifyListeners();
  }

  resetChatroom() {
    _msg = [];
    notifyListeners();
  }

  updatemsg() {
    for (var msg in _msg) {
      msg.isSeen = true;
    }
    notifyListeners();
  }

  setMyLastMsg(String chatroomId, ChatsClass lastMsg) {
    var targetRoom =
        _chatrooms.indexWhere((element) => element.roomId == chatroomId);
    print(targetRoom);
    _chatrooms[targetRoom].roomLastMsg = lastMsg.msg;
    notifyListeners();
  }

  /* Functions */

  getChatrooms() async {
    final snapshot = await chatroomPath.get();
    if (snapshot.exists) {
      final chatroomList = snapshot.children;
      _chatrooms = chatroomList
          .map((e) => ChatroomsClass.fromChatrooms(
              e.value as Map<Object?, Object?>, e.key.toString(), null))
          .toList();
      notifyListeners();
    }
  }

  sendMsg(String msg, String target, BuildContext context) async {
    Map<String, dynamic> msgBody = {
      "senderId": auth.currentUser!.uid,
      "sentOn": DateTime.now().toIso8601String(),
      "msg": msg,
      "isSeen": false,
      "msgType": "text"
    };
    setTempMsg(msgBody);
    final room = HexChatFunctions.isChatroomAvailable(target, context);
    if (room.isNotEmpty) {
      final chatroompath2 =
          database.ref("Chatrooms/${room.first.roomId}/chats").push();
      await chatroompath2.set(msgBody);
    } else {
      final chatroompath = database.ref("Chatrooms").push();
      await chatroompath.set({
        "members": [target, auth.currentUser!.uid],
        "isGroup": false,
      });
    }
  }
}

class ChatroomsClass {
  String roomId, roomLastMsg;
  dynamic targetUser;
  bool isGroup;
  List<String> members;
  ChatroomsClass(this.isGroup, this.members, this.roomId, this.roomLastMsg,
      this.targetUser);
  ChatroomsClass.fromChatrooms(
      Map<Object?, Object?> json, this.roomId, this.targetUser)
      : roomLastMsg = "",
        isGroup = json['isGroup'].toString() == "true" ? true : false,
        members = (json['members'] as List).map((e) => e.toString()).toList();
}

class ChatsClass {
  String msgId, senderid, sentOn, msgType, msg;
  bool isSeen;
  ChatsClass(this.msgId, this.senderid, this.sentOn, this.isSeen, this.msgType,
      this.msg);
  ChatsClass.fromChat(Map<Object?, Object?> json, this.msgId)
      : senderid = json['senderId'].toString(),
        sentOn = json['sentOn'].toString(),
        msgType = json['msgType'].toString(),
        msg = json['msg'].toString(),
        isSeen = json['isSeen'].toString() == "true" ? true : false;
}

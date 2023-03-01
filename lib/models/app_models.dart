import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

class UserModel {
  String uid;
  String phoneNumber, userName, aboutUser;
  UserModel(this.uid, this.phoneNumber, this.userName, this.aboutUser);
  UserModel.fromUser(Map<Object?, Object?> json, this.uid)
      : phoneNumber = json['phoneNumber'].toString(),
        userName = json['userName'].toString(),
        aboutUser = json['about'].toString();
}

class ChatModel {
  String msgId, sender, receiver, msg;
  DateTime sendAt;
  bool isSeen;
  ChatModel(this.msgId, this.sender, this.receiver, this.msg, this.sendAt,
      this.isSeen);
  ChatModel.fromChat(Map<Object?, Object?> json, this.msgId)
      : sender = json['sender'].toString(),
        receiver = (json['users'] as List)
            .firstWhere((element) => element != json['sender'])
            .toString(),
        msg = json['message'].toString(),
        sendAt = DateTime.parse(json['sendAt'].toString()),
        isSeen = json['seen'].toString() == "false" ? false : true;
}

class ChatRoomModel {
  String chatroomId, targetUser;
  ChatModel lastMsg;
  bool isGroupMsg;
  ChatRoomModel(
      this.chatroomId, this.targetUser, this.lastMsg, this.isGroupMsg);
  ChatRoomModel.fromChatrooms(Map<Object?, Object?> json, this.chatroomId,
      this.targetUser, this.lastMsg)
      : isGroupMsg = json['isGroup'].toString() == "true" ? true : false;
}

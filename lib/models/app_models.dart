class UserModel {
  String uid;
  String phoneNumber, userName, aboutUser, image;
  bool isActive;
  int lastSeen;
  UserModel(this.uid, this.phoneNumber, this.userName, this.aboutUser,
      this.image, this.isActive, this.lastSeen);
  UserModel.fromUser(Map<Object?, Object?> json, this.uid)
      : phoneNumber =
            json['phoneNumber'] == "" ? "" : json['phoneNumber'].toString(),
        userName = json['userName'] == "" ? "" : json['userName'].toString(),
        aboutUser = json['about'] == "" ? "" : json['about'].toString(),
        image = json['profileImg'] == "" ? "" : json['profileImg'].toString(),
        isActive = json['isActive'] == false ? false : true,
        lastSeen = json['lastSeen'] == null
            ? 0
            : int.parse(json['lastSeen'].toString());
}

class ChatModel {
  String msgId, sender, msg, msgType;
  DateTime sendAt;
  bool isSeen;
  ChatModel(this.msgId, this.sender, this.msg, this.sendAt, this.isSeen,
      this.msgType);
  ChatModel.fromChat(Map<Object?, Object?> json, this.msgId)
      : sender = json['sender'].toString(),
        msg = json['message'] == "" ? "" : json['message'].toString(),
        sendAt = DateTime.parse(json['sendAt'].toString()),
        msgType = json['type'].toString(),
        isSeen = json['seen'].toString() == "false" ? false : true;
}

class ChatRoomModel {
  String chatroomId;
  dynamic userdata;
  dynamic lastMsg;
  bool isGroupMsg;
  List<String> members;
  ChatRoomModel(this.chatroomId, this.lastMsg, this.isGroupMsg, this.userdata,
      this.members);
  ChatRoomModel.fromChatrooms(
      Map<Object?, Object?> json, this.chatroomId, this.lastMsg, this.userdata)
      : isGroupMsg = json['isGroup'].toString() == "true" ? true : false,
        members = (json['members'] as List).map((e) => e.toString()).toList();
}

// class ChatroomsClass {
//   String roomId, roomLastMsg;
//   dynamic targetUser;
//   bool isGroup;
//   List<String> members;
//   ChatroomsClass(this.isGroup, this.members, this.roomId, this.roomLastMsg,
//       this.targetUser);
//   ChatroomsClass.fromChatrooms(
//       Map<Object?, Object?> json, this.roomId, this.targetUser)
//       : roomLastMsg = "",
//         isGroup = json['isGroup'].toString() == "true" ? true : false,
//         members = (json['members'] as List).map((e) => e.toString()).toList();
// }

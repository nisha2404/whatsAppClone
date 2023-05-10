enum MessageStatus { sent, delivered, seen }

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
  dynamic replyAt;
  DateTime sendAt;
  MessageStatus status;
  // bool isSeen, isDelivered;
  ChatModel(this.msgId, this.sender, this.msg, this.sendAt, this.msgType,
      this.status, this.replyAt);
  ChatModel.fromChat(Map<Object?, Object?> json, this.msgId)
      : sender = json['sender'].toString(),
        msg = json['message'] == "" ? "" : json['message'].toString(),
        sendAt = DateTime.parse(json['sendAt'].toString()),
        msgType = json['type'].toString(),
        status = MessageStatus.values
            .firstWhere((element) => element.name == json['status'].toString()),
        replyAt = json['replyAt'] == null
            ? ""
            : ReplyModel.fromReply(json['replyAt'] as Map<Object?, Object?>);
}

class ChatRoomModel {
  String chatroomId;
  dynamic userdata;
  dynamic lastMsg;
  bool isGroupMsg;
  String groupName;
  String groupImg;
  DateTime createdAt;
  int newChats;
  List<String> members;
  ChatRoomModel(
      this.chatroomId,
      this.lastMsg,
      this.isGroupMsg,
      this.userdata,
      this.groupName,
      this.members,
      this.groupImg,
      this.createdAt,
      this.newChats);
  ChatRoomModel.fromChatrooms(
      Map<Object?, Object?> json, this.chatroomId, this.lastMsg, this.userdata)
      : isGroupMsg = json['isGroup'].toString() == "true" ? true : false,
        newChats = 0,
        members = (json['members'] as List).map((e) => e.toString()).toList(),
        groupName = json["groupName"].toString() == ""
            ? ""
            : json["groupName"].toString(),
        groupImg = json['groupImg'].toString() == ""
            ? ""
            : json['groupImg'].toString(),
        createdAt = DateTime.parse(json['createdAt'].toString());
}

class ReplyModel {
  String id, msg, type, senderId;
  ReplyModel(this.id, this.msg, this.type, this.senderId);
  ReplyModel.fromReply(Map<Object?, Object?> json)
      : msg = json['msg'].toString(),
        id = json['id'].toString(),
        senderId = json['senderId'].toString(),
        type = json['type'].toString();
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

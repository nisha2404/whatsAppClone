class UserModel {
  String uid;
  String phoneNumber;
  UserModel(this.uid, this.phoneNumber);
  UserModel.fromUser(Map<Object?, Object?> json, this.uid)
      : phoneNumber = json['phoneNumber'].toString();
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

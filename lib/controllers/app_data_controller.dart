import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

dynamic prefs;

class AppDataController extends ChangeNotifier {
  String getTimeFormat(DateTime time) {
    if (time.day == DateTime.now().day) {
      return DateFormat('hh:mm a').format(time);
    } else if (time.day == DateTime.now().day - 1) {
      return "Yesterday";
    } else {
      return DateFormat("dd-MM-yyyy").format(time).toString();
    }
  }

// getter and setter for loading.
  bool _loading = false;
  bool get showLoader => _loading;
  setLoader(bool status) {
    _loading = status;
    notifyListeners();
  }

  List<UserModel> _users = [];

  List<UserModel> get getUsers => _users;

  setUsers(List<UserModel> users) {
    _users = users;
    notifyListeners();
  }

  UserModel? _currentuser;

  UserModel get getcurrentUser => _currentuser!;

  setCurrentUser(UserModel user) {
    _currentuser = user;
    notifyListeners();
  }

  updateUser(int index, bool isActive, int lastSeen) {
    _chatRooms[index].userdata.isActive = isActive;
    _chatRooms[index].userdata.lastSeen = lastSeen;
    notifyListeners();
  }

  List<ChatModel> _chats = [];

  List<ChatModel> get getIndividualChats => _chats;

  addChat(ChatModel chat) {
    _chats.add(chat);
    notifyListeners();
  }

  addAllchats(List<ChatModel> chats) {
    _chats = chats;
    notifyListeners();
  }

  updateMessageId(String msgId) {
    final chats = _chats.where((element) => element.msgId == "").toList();
    for (var msg in chats) {
      msg.msgId = msgId;
    }
    notifyListeners();
  }

  updateChatIsSeen() {
    final chats = _chats
        .where((element) => element.status == MessageStatus.delivered)
        .toList();
    for (var chat in chats) {
      chat.status = MessageStatus.seen;
    }
    notifyListeners();
  }

  updateChatIsDelivered() {
    final chats = _chats
        .where((element) => element.status == MessageStatus.sent)
        .toList();
    for (var chat in chats) {
      chat.status = MessageStatus.delivered;
    }
    notifyListeners();
  }

  resetChats() {
    _chats = [];
    notifyListeners();
  }

  List<ChatRoomModel> _chatRooms = [];
  List<ChatRoomModel> get getAllChatRooms => _chatRooms;

  addAllchatRooms(List<ChatRoomModel> chatRooms) {
    _chatRooms = chatRooms;
    notifyListeners();
  }

  addChatRoom(ChatRoomModel chatRoom) {
    if (_chatRooms.any((element) => element.chatroomId == chatRoom.chatroomId))
      return;
    _chatRooms.add(chatRoom);
    notifyListeners();
  }

  resetChatRooms() {
    _chatRooms = [];
    notifyListeners();
  }

  setLastMsg(String chatRoomId, ChatModel chat) {
    int index =
        _chatRooms.indexWhere((element) => element.chatroomId == chatRoomId);
    _chatRooms[index].lastMsg = chat;

    notifyListeners();
  }

  setUnradMessages(String chatRoomId, int unreadMessages) {
    int index =
        _chatRooms.indexWhere((element) => element.chatroomId == chatRoomId);
    _chatRooms[index].newChats = unreadMessages;
    notifyListeners();
  }

  Map<String, dynamic> _tempMsg = {};
  Map<String, dynamic> get getMsg => _tempMsg;

  setTempMsg(Map<String, dynamic> msg) {
    _tempMsg = msg;
    notifyListeners();
  }
}

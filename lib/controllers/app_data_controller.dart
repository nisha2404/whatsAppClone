import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

dynamic preferences;

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
    for (var chat in _chats) {
      chat.isSeen = true;
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

  Map<String, dynamic> _tempMsg = {};
  Map<String, dynamic> get getMsg => _tempMsg;

  setTempMsg(Map<String, dynamic> msg) {
    _tempMsg = msg;
    notifyListeners();
  }
}

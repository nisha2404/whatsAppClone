import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

dynamic preferences;

class AppDataController extends ChangeNotifier {
  bool _loading = false;
  String _currentUid = "";

  String getTimeFormat(DateTime time) {
    if (time.day == DateTime.now().day) {
      return DateFormat('hh:mm a').format(time);
      //  DateFormat.jm()
      //     .format(DateFormat("hh:mm:ss")
      //         .parse("${time.hour}:${time.minute}:${time.second}"))
      //     .toString();
    } else if (time.day == DateTime.now().day - 1) {
      return "Yesterday";
    } else {
      return DateFormat("dd-MM-yyyy").format(time).toString();
    }
  }

  String get getcurrentUid => _currentUid;
  setCurrentUid(String uid) {
    _currentUid = uid;
    notifyListeners();
  }

  resetUid() {
    _currentUid = "";
    notifyListeners();
  }

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

  setLastMsg(ChatRoomModel room) {
    bool isroomAvailable =
        _chatRooms.any((element) => element.chatroomId == room.chatroomId);
    if (isroomAvailable) {
      int index = _chatRooms
          .indexWhere((element) => element.chatroomId == room.chatroomId);
      _chatRooms[index] = room;
    } else {
      _chatRooms.add(room);
    }
    notifyListeners();
  }
}

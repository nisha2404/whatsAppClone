import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';

dynamic preferences;

class AppDataController extends ChangeNotifier {
  bool _loading = false;
  String _currentUid = "";

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

  List _chatRooms = [];
  List get getAllChatRooms => _chatRooms;

  addAllchatRooms(List chatRooms) {
    _chatRooms = chatRooms;
    notifyListeners();
  }
}

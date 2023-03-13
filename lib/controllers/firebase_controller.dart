// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:chatting_app/Screens/Auth/add_profile_info.dart';
import 'package:chatting_app/Screens/Auth/login.dart';
import 'package:chatting_app/Screens/Auth/otp_view.dart';
import 'package:chatting_app/Screens/Dashboard/dashboard.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String receivedVerificationId = "";
final auth = FirebaseAuth.instance;
final database = FirebaseDatabase.instance;
final storage = FirebaseStorage.instance;

class FirebaseController {
  verifyPhone(BuildContext context, String phoneNumber) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    try {
      db.setLoader(true);
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth
                .signInWithCredential(credential)
                .then((value) => {print("You logged in successfully")});
          },
          verificationFailed: (FirebaseAuthException exception) =>
              print(exception.message),
          codeSent: (String verificationId, int? resendToken) {
            receivedVerificationId = verificationId;
            AppServices.pushTo(OtpScreen(phoneNumber: phoneNumber), context);
          },
          codeAutoRetrievalTimeout: (String verificationId) => {});
      db.setLoader(false);
    } catch (e) {
      db.setLoader(false);
      AppServices.showToast(e.toString());
    }
  }

  verifyCode(String code, String phoneNumber, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.setLoader(true);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: receivedVerificationId, smsCode: code);
    await auth.signInWithCredential(credential).then((value) async {
      await getAllUsers(context);

      if (value.user!.phoneNumber!.isNotEmpty) {
        AppServices.pushAndRemove(
            db.getUsers.isNotEmpty ||
                    db.getUsers.any((element) => element.uid == value.user!.uid)
                ? const Dashboard()
                : const AddProfileInfo(),
            context);
      }
    });
    db.setLoader(false);
  }

  addUserProfile(Map<String, dynamic> data, BuildContext context) async {
    final path = database.ref("users/${auth.currentUser!.uid}");
    await path.set(data);
  }

  logOut(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    await auth.signOut().then((value) => {
          db.resetChatRooms(),
          AppServices.pushAndRemove(const LoginScreen(), context)
        });
  }

  msgIsSeen(List<ChatModel> chats, String id) async {
    final unseenChats = chats
        .where((element) =>
            element.isSeen == false &&
            element.receiver == auth.currentUser!.uid)
        .toList();
    for (var chat in unseenChats) {
      await database
          .ref("chatRoom/${createChatRoomId(id)}/chats/${chat.msgId}")
          .update({"seen": true});
    }
  }

  // updateUserPreferences() async {
  //   Map<String, dynamic> online = {
  //     'isActive': true,
  //     'lastSeen': DateTime.now().millisecondsSinceEpoch,
  //   };
  //   Map<String, dynamic> offline = {
  //     'isActive': false,
  //     'lastSeen': DateTime.now().millisecondsSinceEpoch,
  //   };
  //   final connectedRef = database.ref('.info/connected');

  //   connectedRef.onValue.listen((event) async {
  //     final isConnected = event.snapshot.value as bool? ?? false;
  //     if (isConnected) {
  //       await database
  //           .ref()
  //           .child("users")
  //           .child(auth.currentUser!.uid)
  //           .update(online);
  //     } else {
  //       await database
  //           .ref()
  //           .child("users")
  //           .child(auth.currentUser!.uid)
  //           .onDisconnect()
  //           .update(offline);
  //     }
  //   });
  // }

  isCurrentUser(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    auth.currentUser != null
        ? {
            db.setLoader(true),
            getCurrentUser(context),
            await getAllUsers(context),
            db.setLoader(false),
            AppServices.fadeTransitionNavigation(context, const Dashboard())
          }
        : AppServices.fadeTransitionNavigation(context, const LoginScreen());
  }


  Future<void> getAllUsers(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    try {
      // db.setLoader(true);
      await database.ref("users").get().then((value) {
        if (value.exists) {
          db.setUsers(value.children
              .map((e) => UserModel.fromUser(
                  e.value as Map<Object?, Object?>, e.key.toString()))
              .toList());
          // db.setLoader(false);
        } else {
          // db.setLoader(false);
        }
      });
    } catch (e) {
      db.setLoader(false);
      AppServices.showToast(e.toString());
    }
  }

  String createChatRoomId(String id) {
    if (auth.currentUser!.uid.hashCode >= id.hashCode) {
      return "${auth.currentUser!.uid}_vs_$id";
    } else {
      return "${id}_vs_${auth.currentUser!.uid}";
    }
  }

  createChatRoom(Map<String, dynamic> data, String receiverId) async {
    try {
      final path2 =
          database.ref("chatRoom/${createChatRoomId(receiverId)}/chats").push();
      final path = database.ref("chatRoom/${createChatRoomId(receiverId)}");
      final chatroom = await path.get();
      if (chatroom.exists) {
        await path2.set(data);
      } else {
        await path.set({
          "isGroup": false,
          "chats": [data]
        });
      }
    } catch (e) {
      print(e);
    }
  }

  resetMessages(BuildContext context) {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.resetChats();
  }

  bool isSender(ChatModel chat) {
    return chat.sender == auth.currentUser!.uid;
  }

  getChats(String chatRoomKey) async {
    final path = database.ref("chatRoom/$chatRoomKey/chats");
    await path.get();
  }

  setLastMsg(DatabaseEvent event, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatroomKey = event.snapshot.key.toString();
    final userPath = await database.ref("users").get();
    final user = userPath.children.firstWhere((element) =>
        element.key ==
        chatroomKey
            .toString()
            .split("_vs_")
            .firstWhere((element) => element != auth.currentUser!.uid)
            .toString());
    final msgSnapshot =
        await database.ref("chatRoom/$chatroomKey/chats").orderByValue().get();
    if (msgSnapshot.exists) {
      final lastMsg = msgSnapshot.children.last;
      db.setLastMsg(ChatRoomModel.fromChatrooms(
          event.snapshot.value as Map<Object?, Object?>,
          chatroomKey,
          chatroomKey
              .split("_vs_")
              .firstWhere((element) => element != auth.currentUser!.uid)
              .toString(),
          ChatModel.fromChat(
              lastMsg.value as Map<Object?, Object?>, lastMsg.key.toString()),
          UserModel.fromUser(
              user.value as Map<Object?, Object?>, user.key.toString())));
    }
  }

  setNewChatRoom(DatabaseEvent event, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatRoomKey = event.snapshot.key;
    final userPath = await database.ref("users").get();
    final user = userPath.children.firstWhere((element) =>
        element.key ==
        chatRoomKey
            .toString()
            .split("_vs_")
            .firstWhere((element) => element != auth.currentUser!.uid)
            .toString());
    final message =
        await database.ref("chatRoom/$chatRoomKey/chats").orderByValue().get();
    if (message.exists) {
      final lastMsg = message.children.last;
      db.setLastMsg(ChatRoomModel.fromChatrooms(
          event.snapshot.value as Map<Object?, Object?>,
          event.snapshot.key.toString(),
          event.snapshot.key
              .toString()
              .split("_vs_")
              .firstWhere((element) => element != auth.currentUser!.uid),
          ChatModel.fromChat(
              lastMsg.value as Map<Object?, Object?>, lastMsg.key.toString()),
          UserModel.fromUser(
              user.value as Map<Object?, Object?>, user.key.toString())));
      getAllUsers(context);
    }
  }

  getAllChatRooms(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatroomPath = database.ref("chatRoom");
    var snapshot = await chatroomPath.get();
    if (snapshot.exists) {
      db.setLoader(true);
      final List<ChatRoomModel> rooms = [];
      final chatroomList = snapshot.children
          .where((e) => e.key.toString().contains(auth.currentUser!.uid))
          .toList();
      for (var room in chatroomList) {
        final userPath = await database.ref("users").get();
        final user = userPath.children.firstWhere((element) =>
            element.key ==
            room.key
                .toString()
                .split("_vs_")
                .firstWhere((element) => element != auth.currentUser!.uid)
                .toString());
        final msgPath = database.ref("chatRoom/${room.key}/chats");
        final msgSnapshot = await msgPath.get();
        if (msgSnapshot.exists) {
          final lastmsg = msgSnapshot.children.last;
          rooms.add(ChatRoomModel.fromChatrooms(
              room.value as Map<Object?, Object?>,
              room.key.toString(),
              room.key
                  .toString()
                  .split("_vs_")
                  .firstWhere((element) => element != auth.currentUser!.uid)
                  .toString(),
              ChatModel.fromChat(lastmsg.value as Map<Object?, Object?>,
                  lastmsg.key.toString()),
              UserModel.fromUser(
                  user.value as Map<Object?, Object?>, user.key.toString())));
        }
      }
      db.addAllchatRooms(rooms);
      db.setLoader(false);
    } else {
      db.setLoader(false);
      null;
    }
  }

  getCurrentUser(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final path = database.ref("users/${auth.currentUser!.uid}");
    path.get().then((value) => db.setCurrentUser(UserModel.fromUser(
        value.value as Map<Object?, Object?>, value.key.toString())));
  }
}

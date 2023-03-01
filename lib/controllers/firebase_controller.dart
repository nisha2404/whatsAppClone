// ignore_for_file: use_build_context_synchronously

import 'package:chatting_app/Screens/Auth/add_profile_info.dart';
import 'package:chatting_app/Screens/Auth/login.dart';
import 'package:chatting_app/Screens/Auth/otp_view.dart';
import 'package:chatting_app/Screens/Dashboard/dashboard.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String receivedVerificationId = "";

class FirebaseController {
  final auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance;

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
    final users = db.getUsers;
    db.setLoader(true);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: receivedVerificationId, smsCode: code);
    await auth.signInWithCredential(credential).then((value) async {
      final path = database.ref("users/${value.user!.uid}");
      await path.set({"phoneNumber": phoneNumber}).then(
          (value) => getAllUsers(context));
      db.setCurrentUid(value.user!.uid);

      AppServices.pushAndRemove(
          users
                  .where((element) => element.uid == value.user!.uid)
                  .first
                  .userName
                  .isEmpty
              ? const AddProfileInfo()
              : const Dashboard(),
          context);
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
          db.resetUid(),
          AppServices.pushAndRemove(const LoginScreen(), context)
        });
  }

  isCurrentUser(BuildContext context) {
    final db = Provider.of<AppDataController>(context, listen: false);
    auth.currentUser != null
        ? {
            db.setCurrentUid(auth.currentUser!.uid),
            getAllUsers(context),
            AppServices.fadeTransitionNavigation(context, const Dashboard())
          }
        : AppServices.fadeTransitionNavigation(context, const LoginScreen());
  }

  Future<void> getAllUsers(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    try {
      db.setLoader(true);
      await database.ref("users").get().then((value) {
        if (value.exists) {
          db.setUsers(value.children
              .map((e) => UserModel.fromUser(
                  e.value as Map<Object?, Object?>, e.key.toString()))
              .toList());
          db.setLoader(false);
        } else {
          db.setLoader(false);
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

  ChatModel getLastMsg(DataSnapshot chats) {
    print((chats.value as Map<Object?, Object?>)['chats']);
    var lastmsg =
        ((chats.value as Map<Object?, Object?>)['chats'] as List).last;
    return ChatModel.fromChat(
        lastmsg.value as Map<Object?, Object?>, lastmsg.key.toString());
  }

  setLastMsg(DatabaseEvent event, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatroomKey = event.snapshot.key.toString();
    final msgSnapshot =
        await database.ref("chatRoom/$chatroomKey/chats").orderByValue().get();
    if (msgSnapshot.exists) {
      final lastMsg = msgSnapshot.children.last;
      print(lastMsg);
      db.setLastMsg(ChatRoomModel.fromChatrooms(
          event.snapshot.value as Map<Object?, Object?>,
          chatroomKey,
          chatroomKey
              .split("_vs_")
              .firstWhere((element) => element != auth.currentUser!.uid)
              .toString(),
          ChatModel.fromChat(
              lastMsg.value as Map<Object?, Object?>, lastMsg.key.toString())));
    }
  }

  getAllChatRooms(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatroomPath = database.ref("chatRoom");

    var snapshot = await chatroomPath.get();
    if (snapshot.exists) {
      final List<ChatRoomModel> rooms = [];
      final chatroomList = snapshot.children
          .where((e) => e.key.toString().contains(auth.currentUser!.uid))
          .toList();
      for (var room in chatroomList) {
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
                  lastmsg.key.toString())));
        }
      }
      db.addAllchatRooms(rooms);
    } else {
      null;
    }
  }
}

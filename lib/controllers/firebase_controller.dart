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

// verification id for Otp verification.
String receivedVerificationId = "";

// instance of firebase authentication.
final auth = FirebaseAuth.instance;

// instance of firebase Database.
final database = FirebaseDatabase.instance;

// instance of firebase Storage.
final storage = FirebaseStorage.instance;

class FirebaseController {
  // authentication verify phone number
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

// authentication verify otp code
  verifyCode(String code, String phoneNumber, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.setLoader(true);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: receivedVerificationId, smsCode: code);
    await auth.signInWithCredential(credential).then((value) async {
      await getAllUsers(context);

      if (value.user!.phoneNumber!.isNotEmpty) {
        AppServices.pushAndRemove(
            db.getUsers.isNotEmpty
                ? (db.getUsers.any((element) => element.uid == value.user!.uid)
                    ? const Dashboard()
                    : const AddProfileInfo())
                : const AddProfileInfo(),
            context);
        db.getUsers.isNotEmpty
            ? db.setCurrentUser(db.getUsers
                .where((element) => element.uid == value.user!.uid)
                .toList()
                .first)
            : null;
      } else {
        db.setCurrentUser(db.getUsers
            .firstWhere((element) => element.uid == value.user!.uid));
        AppServices.pushAndRemove(const AddProfileInfo(), context);
      }
    });
    db.setLoader(false);
  }

// authentication add user profile to database
  addUserProfile(Map<String, dynamic> data, BuildContext context) async {
    final path = database.ref("users/${auth.currentUser!.uid}");
    await path.set(data);
  }

// logout current user and navigate to login screen.
  logOut(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    await auth.signOut().then((value) => {
          db.resetChatRooms(),
          AppServices.pushAndRemove(const LoginScreen(), context)
        });
  }

// function to check the message is seen by the target user or not.
  msgIsSeen(BuildContext context, String roomId) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final path = database.ref("chatRoom/$roomId/chats");
    final snapshot = await path.get();
    if (snapshot.exists) {
      final lastMsg = snapshot.children.last.value as Map<Object?, Object?>;
      bool isSentByMe = lastMsg['sender'].toString() == auth.currentUser!.uid;
      if (isSentByMe) {
        null;
      } else {
        final db = Provider.of<AppDataController>(context, listen: false);
        var data = db.getIndividualChats
            .where((element) => element.status == MessageStatus.delivered)
            .toList()
            .map((e) => e.msgId)
            .toList();
        for (var msgid in data) {
          final msgPath = database.ref("chatRoom/$roomId/chats/$msgid");
          await msgPath.update({"status": MessageStatus.seen.name});
        }
      }
    }
  }

  markAsSeen(String? chatRoomId, ChatModel chat) async {
    bool isSentByme = chat.sender == auth.currentUser!.uid;
    if (isSentByme) {
      return;
    } else {
      if (chat.status == MessageStatus.delivered) {
        await database
            .ref("chatRoom/$chatRoomId/chats/${chat.msgId}")
            .update({"status": MessageStatus.seen.name});
      } else {
        return;
      }
    }
  }

  markAsDelivered(String? chatRoomId, bool isGroup, ChatModel chat) async {
    bool isSentByme = chat.sender == auth.currentUser!.uid;
    if (!isGroup) {
      if (isSentByme) {
        return;
      } else {
        if (chat.status == MessageStatus.sent) {
          await database
              .ref("chatRoom/$chatRoomId/chats/${chat.msgId}")
              .update({"status": MessageStatus.delivered.name});
        } else {
          return;
        }
      }
    } else {
      return;
    }
  }

// function to check the current user or not if current user then navigate to dashboard or navigate to login
  isCurrentUser(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    auth.currentUser != null
        ? {
            db.setLoader(true),
            getCurrentUser(context),
            await getAllUsers(context),
            // await getallChatRooms(context),
            db.setLoader(false),
            AppServices.fadeTransitionNavigation(context, const Dashboard())
          }
        : AppServices.fadeTransitionNavigation(context, const LoginScreen());
  }

// firebase function to get all the users registered in the app.
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

// function to check if the chatRoom is available or not if chatroom is available then return the chatRoom.
  List<ChatRoomModel> isChatRoomAvailable(
      BuildContext context, String targetid) {
    final db = Provider.of<AppDataController>(context, listen: false);
    final chatRooms = db.getAllChatRooms;
    final List<ChatRoomModel> availableRooms = [];
    for (var room in chatRooms) {
      if (room.members.any((e) => e == targetid) &&
          room.members.any((element) => element == auth.currentUser!.uid)) {
        availableRooms.add(room);
      } else {
        null;
      }
    }
    return availableRooms;
  }

// function to create a group
  createGroupChatRoom(Map<String, dynamic> data) async {
    final path = database.ref("chatRoom").push();
    await path.set(data);
  }

  // getallChatRooms(BuildContext context) async {
  //   final db = Provider.of<AppDataController>(context, listen: false);
  //   final path = database.ref("chatRoom");
  //   final snapshot = await path.get();
  //   if (snapshot.exists) {
  //     final List<ChatRoomModel> rooms = [];
  //     final chatRoomList = snapshot.children.where((element) =>
  //         ((element.value as Map<Object?, Object?>)['members'] as List)
  //             .contains(auth.currentUser!.uid)).toList();
  //             final targetUserId = snapshot.children.map((e) => ((e.value as Map<Object?, Object?>)['members'] as List).firstWhere((element) => element != auth.currentUser!.uid)).toList();
  //   }
  // }

// function to send message in the group
  sendGroupMessage(String chatRoomId, String msg, String type) async {
    Map<String, dynamic> data = {
      "status": MessageStatus.sent.name,
      "sender": auth.currentUser!.uid,
      "sendAt": DateTime.now().toIso8601String(),
      "message": msg,
      "type": type
    };
    final path = database.ref("chatRoom/$chatRoomId/chats").push();

    await path.set(data);
  }

// function to create a chatRoom or if existing then send message to database.
  Future<bool> createChatRoom(
      Map<String, dynamic> data, String targetid, BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);

    final List<ChatRoomModel> rooms = isChatRoomAvailable(context, targetid)
        .where((element) => element.isGroupMsg == false)
        .toList();
    if (rooms.isEmpty) {
      db.setTempMsg(data);
      final path = database.ref("chatRoom").push();
      await path.set({
        "members": [targetid, auth.currentUser!.uid],
        "isGroup": false,
        "groupName": "",
        "groupImg": "",
        "createdAt": DateTime.now().toIso8601String()
      });
      return true;
    } else {
      final path2 =
          database.ref("chatRoom/${rooms.first.chatroomId}/chats").push();
      await path2.set(data);

      return true;
    }
  }

// function to reset all chats in appdataController.
  resetMessages(BuildContext context) {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.resetChats();
  }

// function to check if the current user is sender or not.
  bool isSender(ChatModel chat) {
    return chat.sender == auth.currentUser!.uid;
  }

  // function to check if the message is delivered or not.

// function to get all the chats of a chatRoom.
  getChats(String chatRoomKey) async {
    final path = database.ref("chatRoom/$chatRoomKey/chats");
    await path.get();
  }

  getCurrentUser(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    final path = database.ref("users/${auth.currentUser!.uid}");
    path.get().then((value) => db.setCurrentUser(UserModel.fromUser(
        value.value as Map<Object?, Object?>, value.key.toString())));
  }
}

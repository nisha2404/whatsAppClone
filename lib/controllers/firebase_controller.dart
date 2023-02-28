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
    db.setLoader(true);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: receivedVerificationId, smsCode: code);
    await auth.signInWithCredential(credential).then((value) {
      final path = database.ref("users/${value.user!.uid}");
      path.set({"phoneNumber": phoneNumber});
      db.setCurrentUid(value.user!.uid);
      AppServices.pushAndRemove(const AddProfileInfo(), context);
    });
    db.setLoader(false);
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

  getAllChatRooms(BuildContext context) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    await database
        .ref("chatRoom")
        .get()
        .then((value) => db.addAllchatRooms(value.children.toList()));
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/icons_and_images.dart';
import '../../../components/shimmers/profile_img_shimmer.dart';
import '../../../helpers/style_sheet.dart';

class ChatViewTab extends StatefulWidget {
  const ChatViewTab({super.key});

  @override
  State<ChatViewTab> createState() => _ChatViewTabState();
}

class _ChatViewTabState extends State<ChatViewTab> {
  @override
  void initState() {
    super.initState();
    getStuff();
  }

  getStuff() async {
    final db = Provider.of<AppDataController>(context, listen: false);
    if (!await rebuild()) return;
    db.resetChatRooms();
    await FirebaseController().getAllChatRooms(context);
  }

  // final List<UserModel> _users = [];

  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return false;
    }

    setState(() {});
    return true;
  }

  // getUsers() {
  //   final db = Provider.of<AppDataController>(context, listen: false);
  //   final chatRooms = db.getAllChatRooms;
  //   for (var user in db.getUsers) {
  //     for (var chats in chatRooms) {
  //       if (user.uid == chats.targetUser) {
  //         if (_users.any((element) => element.uid == user.uid)) {
  //           null;
  //         } else {
  //           _users.add(user);
  //         }
  //       } else {
  //         null;
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chatRooms = db.getAllChatRooms;
    chatRooms.sort((a, b) => b.lastMsg.sendAt.compareTo(a.lastMsg.sendAt));
    return db.showLoader
        ? const Center(child: CircularProgressIndicator.adaptive())
        : ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: chatRooms.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              // getUsers();
              return ListTile(
                onTap: () => AppServices.pushTo(
                    ChatRoom(user: chatRooms[i].userdata), context),
                leading: Container(
                    height: 45.sp,
                    width: 45.sp,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(400.r),
                      child: chatRooms[i].userdata.image == ""
                          ? Image.asset(AppImages.avatarPlaceholder,
                              fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: chatRooms[i].userdata.image,
                              placeholder: (context, url) =>
                                  ProfileImageShimmer(height: 150, width: 150)),
                    )),
                title: Text(chatRooms[i].userdata.phoneNumber,
                    style: GetTextTheme.sf16_bold),
                subtitle: Text(
                    chatRooms[i].lastMsg.msgType == "text"
                        ? chatRooms[i].lastMsg.msg
                        : chatRooms[i].lastMsg.msgType == "imageWithText"
                            ? chatRooms[i].lastMsg.msg.split("__").last
                            : "Image",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GetTextTheme.sf14_regular
                        .copyWith(color: AppColors.grey150)),
                trailing: Text(db.getTimeFormat(chatRooms[i].lastMsg.sendAt),
                    style: GetTextTheme.sf12_regular
                        .copyWith(color: AppColors.grey150)),
              );
            });
  }
}

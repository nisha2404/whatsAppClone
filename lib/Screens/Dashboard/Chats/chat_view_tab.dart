import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
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
    final db = Provider.of<AppDataController>(context, listen: false);
    db.resetChatRooms();
    FirebaseController().getAllChatRooms(context);
  }

  final List<UserModel> _users = [];

  getUsers() {
    final db = Provider.of<AppDataController>(context, listen: false);
    for (var user in db.getUsers) {
      for (var chats in db.getAllChatRooms) {
        if (user.uid == chats.targetUser) {
          if (_users.any((element) => element.uid == user.uid)) {
            null;
          } else {
            _users.add(user);
          }
        } else {
          null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chatRooms = db.getAllChatRooms;

    return db.showLoader
        ? const Center(child: CircularProgressIndicator.adaptive())
        : ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: chatRooms.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              getUsers();
              return ListTile(
                onTap: () =>
                    AppServices.pushTo(ChatRoom(user: _users[i]), context),
                leading: Container(
                    height: 45.sp,
                    width: 45.sp,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(400.r),
                      child: _users[i].image == ""
                          ? Image.asset(AppImages.avatarPlaceholder,
                              fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: _users[i].image,
                              placeholder: (context, url) =>
                                  ProfileImageShimmer(height: 150, width: 150)),
                    )),
                title:
                    Text(_users[i].phoneNumber, style: GetTextTheme.sf16_bold),
                subtitle: Text(
                    chatRooms[i].lastMsg.msgType == "text" ||
                            chatRooms[i].lastMsg.msgType == "imageWithText"
                        ? chatRooms[i].lastMsg.msg
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

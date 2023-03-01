import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/icons_and_images.dart';
import '../../../helpers/style_sheet.dart';

class ChatViewTab extends StatefulWidget {
  const ChatViewTab({super.key});

  @override
  State<ChatViewTab> createState() => _ChatViewTabState();
}

class _ChatViewTabState extends State<ChatViewTab> {
  final _auth = FirebaseAuth.instance;
  final _firebase = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    FirebaseController().getAllChatRooms(context);
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
              final user = db.getUsers
                  .where((e) => e.uid == chatRooms[i].targetUser)
                  .toList();

              return ListTile(
                onTap: () =>
                    AppServices.pushTo(ChatRoom(user: user[i]), context),
                leading: Container(
                    // padding: EdgeInsets.all(7.sp),
                    height: 45.sp,
                    width: 45.sp,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(400.r),
                      child: Image.asset(AppImages.avatarPlaceholder,
                          fit: BoxFit.cover),
                    )),
                title: Text(user[i].phoneNumber, style: GetTextTheme.sf16_bold),
                subtitle: Text(chatRooms[i].lastMsg.msg,
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

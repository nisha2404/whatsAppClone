import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../helpers/icons_and_images.dart';
import '../../../helpers/style_sheet.dart';

class ChatViewTab extends StatefulWidget {
  const ChatViewTab({super.key});

  @override
  State<ChatViewTab> createState() => _ChatViewTabState();
}

class _ChatViewTabState extends State<ChatViewTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: 20,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () => AppServices.pushTo(const ChatRoom(), context),
            leading: Container(
                // padding: EdgeInsets.all(7.sp),
                height: 36.sp,
                width: 36.sp,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(400.r),
                  child: Image.asset(AppImages.avatarPlaceholder,
                      fit: BoxFit.cover),
                )),
            title: const Text("John Doe", style: GetTextTheme.sf16_bold),
            subtitle: Text("Last message",
                style: GetTextTheme.sf14_regular
                    .copyWith(color: AppColors.grey150)),
            trailing: Text("Yesterday",
                style: GetTextTheme.sf12_regular
                    .copyWith(color: AppColors.grey150)),
          );
        });
  }
}

import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
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
  @override
  void initState() {
    super.initState();
    FirebaseController().getAllChatRooms(context);
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chatRooms = db.getAllChatRooms;
    return ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: chatRooms.length,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () => {},
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

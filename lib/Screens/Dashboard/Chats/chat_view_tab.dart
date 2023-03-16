import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/components/shimmers/chat_room_tile_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/icons_and_images.dart';
import '../../../components/shimmers/profile_img_shimmer.dart';
import '../../../helpers/base_getters.dart';
import '../../../helpers/style_sheet.dart';
import 'chatroom.dart';

class ChatViewTab extends StatefulWidget {
  const ChatViewTab({super.key});

  @override
  State<ChatViewTab> createState() => _ChatViewTabState();
}

class _ChatViewTabState extends State<ChatViewTab> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chatRooms = db.getAllChatRooms
        .where((element) =>
            element.members.any((element) => element == auth.currentUser!.uid))
        .toList();
    chatRooms.sort((a, b) => b.lastMsg.sendAt.compareTo(a.lastMsg.sendAt));
    return db.showLoader
        ? Column(
            children: List.generate(5, (index) => const ChatRoomTileShimmer()))
        : (chatRooms.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Expanded(flex: 1, child: SizedBox()),
                  Image.asset(AppGiffs.chatGiff2, fit: BoxFit.cover),
                  const Text(
                      "Start your first conversation by tapping on the button below.",
                      textAlign: TextAlign.center,
                      style: GetTextTheme.sf22_bold),
                  const Expanded(flex: 3, child: SizedBox()),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: chatRooms.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final user = chatRooms[i].userdata as UserModel;
                  final lastmsg = chatRooms[i].lastMsg as ChatModel;
                  // getUsers();
                  return ListTile(
                    onTap: () =>
                        AppServices.pushTo(ChatRoom(user: user), context),
                    leading: Container(
                        height: 45.sp,
                        width: 45.sp,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(400.r),
                          child: user.image == ""
                              ? Image.asset(AppImages.avatarPlaceholder,
                                  fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: user.image,
                                  placeholder: (context, url) =>
                                      ProfileImageShimmer(
                                          height: 150.sp, width: 150.sp)),
                        )),
                    title:
                        Text(user.phoneNumber, style: GetTextTheme.sf16_bold),
                    subtitle: Row(
                      children: [
                        FirebaseController().isSender(lastmsg)
                            ? user.isActive == false
                                ? Icon(Icons.done,
                                    size: 18.sp, color: AppColors.grey150)
                                : Icon(Icons.done_all,
                                    size: 18.sp,
                                    color: lastmsg.isSeen
                                        ? AppColors.primaryColor
                                        : AppColors.grey150)
                            : const SizedBox(),
                        AppServices.addWidth(5.w),
                        Expanded(
                          child: Text(
                              lastmsg.msgType == "text"
                                  ? lastmsg.msg
                                  : lastmsg.msgType == "imageWithText"
                                      ? lastmsg.msg.split("__").last
                                      : "📸 Image",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GetTextTheme.sf14_regular
                                  .copyWith(color: AppColors.grey150)),
                        ),
                      ],
                    ),
                    trailing: Text(db.getTimeFormat(lastmsg.sendAt),
                        style: GetTextTheme.sf12_regular
                            .copyWith(color: AppColors.grey150)),
                  );
                }));
  }
}

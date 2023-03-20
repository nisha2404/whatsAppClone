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
    chatRooms.sort((a, b) => b.lastMsg == null
        ? b.createdAt.compareTo(a.createdAt)
        : b.lastMsg.sendAt.compareTo(a.lastMsg.sendAt));
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
                      "Start a new conversation by tapping on the button below.",
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
                  final lastmsg = chatRooms[i].lastMsg;

                  // getUsers();
                  return ListTile(
                      onTap: () => AppServices.pushTo(
                          ChatRoom(
                              user: user,
                              chatRoomModel: chatRooms[i].isGroupMsg == true
                                  ? chatRooms[i]
                                  : null),
                          context),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                              height: 45.sp,
                              width: 45.sp,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(400.r),
                                child: chatRooms[i].isGroupMsg
                                    ? CachedNetworkImage(
                                        imageUrl: chatRooms[i].groupImg,
                                        placeholder: (context, url) =>
                                            ProfileImageShimmer(
                                                height: 150.sp, width: 150.sp),
                                      )
                                    : (user.image == ""
                                        ? Image.asset(
                                            AppImages.avatarPlaceholder,
                                            fit: BoxFit.cover)
                                        : CachedNetworkImage(
                                            imageUrl: user.image,
                                            placeholder: (context, url) =>
                                                ProfileImageShimmer(
                                                    height: 150.sp,
                                                    width: 150.sp))),
                              )),
                          chatRooms[i].isGroupMsg
                              ? const SizedBox()
                              : Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Icon(Icons.circle,
                                      size: 15.sp,
                                      color: user.isActive == true
                                          ? AppColors.greenColor
                                          : AppColors.grey150),
                                )
                        ],
                      ),
                      title: Text(
                          chatRooms[i].isGroupMsg
                              ? chatRooms[i].groupName
                              : user.phoneNumber,
                          style: GetTextTheme.sf16_bold),
                      subtitle: lastmsg == null
                          ? const SizedBox()
                          : Row(
                              children: [
                                FirebaseController().isSender(lastmsg)
                                    ? AppServices.getMessageStatusIcon(lastmsg)
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
                      trailing: lastmsg == null
                          ? const SizedBox()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(db.getTimeFormat(lastmsg.sendAt),
                                    style: GetTextTheme.sf12_regular
                                        .copyWith(color: AppColors.grey150)),
                                AppServices.addHeight(2.h),
                                FirebaseController()
                                            .isSender(chatRooms[i].lastMsg) ||
                                        chatRooms[i].isGroupMsg
                                    ? const SizedBox()
                                    : (chatRooms[i].newChats == 0
                                        ? const SizedBox()
                                        : Text(
                                            "${chatRooms[i].newChats} new ${chatRooms[i].newChats == 1 ? "message" : "messages"}",
                                            style: GetTextTheme.sf12_regular
                                                .copyWith(
                                                    color: AppColors
                                                        .primaryColor)))
                              ],
                            ));
                }));
  }
}

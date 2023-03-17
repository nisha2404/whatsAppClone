// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/shimmers/profile_img_shimmer.dart';
import '../../../../helpers/base_getters.dart';
import '../../../../helpers/icons_and_images.dart';
import '../../../../helpers/style_sheet.dart';

lastSeenMessage(int lastSeen) {
  DateTime now = DateTime.now();
  Duration differenceDuration =
      now.difference(DateTime.fromMillisecondsSinceEpoch(lastSeen));
  String finalMessage = differenceDuration.inSeconds > 59
      ? differenceDuration.inMinutes > 59
          ? differenceDuration.inDays > 23
              ? "${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : "days"}"
              : "${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? "hour" : "hours"}"
          : "${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? "minute" : "minutes"}"
      : "few Moments";

  return finalMessage;
}

dynamic chatRoomAppBar(UserModel user, BuildContext context,
    [ChatRoomModel? chatRoomModel]) {
  return AppBar(
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    elevation: 0,
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.whiteColor,
    systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            constraints: BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
            onPressed: () => AppServices.popView(context),
            icon: const Icon(Icons.arrow_back)),
        Container(
            height: 36.sp,
            width: 36.sp,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(400.r),
                child: chatRoomModel != null
                    ? CachedNetworkImage(imageUrl: chatRoomModel.groupImg)
                    : (user.image == ""
                        ? Image.asset(AppImages.avatarPlaceholder,
                            fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: user.image,
                            placeholder: (context, url) => ProfileImageShimmer(
                                height: 150.sp, width: 150.sp))))),
        AppServices.addWidth(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  chatRoomModel == null
                      ? user.phoneNumber
                      : chatRoomModel.groupName,
                  style: GetTextTheme.sf16_bold),
              chatRoomModel == null
                  ? Text(
                      user.isActive == true
                          ? "Online"
                          : "${lastSeenMessage(user.lastSeen)} ago",
                      style: GetTextTheme.sf12_regular)
                  : Row(children: [
                      ...List.generate(
                          1,
                          (index) => Text(chatRoomModel.members[index],
                              style: GetTextTheme.sf12_regular)),
                      const Text("....", style: GetTextTheme.sf12_regular)
                    ]),
            ],
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
          onPressed: () {},
          splashRadius: 20.r,
          icon: const Icon(Icons.video_call)),
      IconButton(
          onPressed: () {}, splashRadius: 20.r, icon: const Icon(Icons.call)),
      IconButton(
          onPressed: () {},
          splashRadius: 20.r,
          icon: const Icon(Icons.more_vert))
    ],
  );
}

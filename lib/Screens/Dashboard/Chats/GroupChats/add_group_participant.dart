// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/GroupChats/create_group.dart';
import 'package:chatting_app/components/shimmers/chat_image_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../components/shimmers/profile_img_shimmer.dart';
import '../../../../helpers/icons_and_images.dart';
import '../../../../models/app_models.dart';

class AddGroupParticipants extends StatefulWidget {
  const AddGroupParticipants({super.key});

  @override
  State<AddGroupParticipants> createState() => _AddGroupParticipantsState();
}

class _AddGroupParticipantsState extends State<AddGroupParticipants> {
  @override
  void initState() {
    super.initState();
    getSession();
  }

  getSession() async {
    if (!await rebuild()) return;
    FirebaseController().getAllUsers(context);
  }

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

  List<UserModel> participants = [];

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final users = db.getUsers
        .where((element) => element.uid != auth.currentUser!.uid)
        .toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () => AppServices.pushTo(
              CreateGroupView(participants: participants), context),
          child: const Icon(Icons.arrow_forward, color: AppColors.whiteColor)),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("New Group", style: GetTextTheme.sf18_bold),
            Text(
                participants.isEmpty
                    ? 'Add Participants'
                    : '${participants.length} of ${users.length} selected',
                style: GetTextTheme.sf12_regular)
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              splashRadius: 20.r,
              icon: const Icon(Icons.search)),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.sp),
        child: Column(
          children: [
            participants.isEmpty
                ? const SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 92.h,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ListView.builder(
                              itemCount: participants.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                return AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.sp, vertical: 5.sp),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 60.sp,
                                          width: 60.sp,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200.r),
                                            child: participants[i].image == ""
                                                ? Image.asset(
                                                    AppImages.avatarPlaceholder,
                                                    fit: BoxFit.cover)
                                                : CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl:
                                                        participants[i].image,
                                                    placeholder:
                                                        (context, url) =>
                                                            ChatImageShimmer(
                                                                height: 50.sp,
                                                                width: 50.sp),
                                                  ),
                                          ),
                                        ),
                                        AppServices.addHeight(3.h),
                                        Text(participants[i].userName,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: GetTextTheme.sf14_regular)
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: AppColors.blackColor.withOpacity(0.15),
                      )
                    ],
                  ),
            Expanded(
              child: SizedBox(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return ListTile(
                        onTap: () => setState(() {
                          if (participants
                              .any((element) => element.uid == users[i].uid)) {
                            participants.remove(users[i]);
                          } else {
                            participants.add(users[i]);
                          }
                        }),
                        title: Text(users[i].phoneNumber,
                            style: GetTextTheme.sf18_bold),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                                // padding: EdgeInsets.all(7.sp),
                                height: 45.sp,
                                width: 45.sp,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(400.r),
                                  child: users[i].image == ""
                                      ? Image.asset(AppImages.avatarPlaceholder,
                                          fit: BoxFit.cover)
                                      : CachedNetworkImage(
                                          imageUrl: users[i].image,
                                          placeholder: (context, url) =>
                                              ProfileImageShimmer(
                                                  height: 150, width: 150)),
                                )),
                            participants.any((e) => e.uid == users[i].uid)
                                ? Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: AppColors.whiteColor,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.check_circle,
                                            size: 20.sp,
                                            color: AppColors.greenColor)),
                                  )
                                : const SizedBox()
                          ],
                        ),
                        subtitle: Text(users[i].aboutUser,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GetTextTheme.sf12_regular
                                .copyWith(color: AppColors.grey150)),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        AppServices.addHeight(10.sp),
                    itemCount: users.length),
              ),
            )
          ],
        ),
      )),
    );
  }
}

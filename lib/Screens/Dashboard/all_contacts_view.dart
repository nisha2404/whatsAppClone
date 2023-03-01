import 'package:chatting_app/Screens/Dashboard/Chats/chatroom.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../helpers/icons_and_images.dart';

class AllContactsView extends StatefulWidget {
  const AllContactsView({super.key});

  @override
  State<AllContactsView> createState() => _AllContactsViewState();
}

class _AllContactsViewState extends State<AllContactsView> {
  @override
  void initState() {
    super.initState();
    FirebaseController().getAllUsers(context);
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final users = db.getUsers
        .where((element) => element.uid != db.getcurrentUid)
        .toList();
    return Scaffold(
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
            const Text("Select contact", style: GetTextTheme.sf18_bold),
            Text("${users.length} contacts", style: GetTextTheme.sf12_regular)
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              splashRadius: 20.r,
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {},
              splashRadius: 20.r,
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.sp),
        child: Column(
          children: [
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () =>
                        AppServices.pushTo(ChatRoom(user: users[i]), context),
                    title: Text(users[i].phoneNumber,
                        style: GetTextTheme.sf18_bold),
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
                    subtitle: Text(users[i].aboutUser,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GetTextTheme.sf12_regular
                            .copyWith(color: AppColors.grey150)),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    AppServices.addHeight(10.sp),
                itemCount: users.length)
          ],
        ),
      )),
    );
  }
}

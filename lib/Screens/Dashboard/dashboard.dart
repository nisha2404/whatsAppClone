import 'package:chatting_app/Screens/Dashboard/Chats/chat_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/all_contacts_view.dart';
import 'package:chatting_app/Screens/Dashboard/calls/call_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/community/community_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/status/status_view_tab.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../helpers/icons_and_images.dart';
import '../../app_config.dart';
import '../../helpers/style_sheet.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> tabs = [
    Tab(
      icon: Image.asset(AppIcons.communityIcon,
          height: 18.sp, color: AppColors.whiteColor),
    ),
    const Tab(child: Text("Chats", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Status", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Calls", style: GetTextTheme.sf16_bold)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                AppServices.pushTo(const AllContactsView(), context),
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.chat)),
        body: DefaultTabController(
          initialIndex: 1,
          length: tabs.length,
          child: NestedScrollView(
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.whiteColor,
                      pinned: true,
                      floating: true,
                      snap: true,
                      title: const Text(AppConfig.appName),
                      automaticallyImplyLeading: false,
                      systemOverlayStyle: const SystemUiOverlayStyle(
                          statusBarBrightness: Brightness.light,
                          statusBarIconBrightness: Brightness.light,
                          statusBarColor: AppColors.primaryColor),
                      actions: [
                        IconButton(
                            onPressed: () {},
                            splashRadius: 20.r,
                            icon: const Icon(Icons.camera_alt_outlined)),
                        IconButton(
                            onPressed: () {},
                            splashRadius: 20.r,
                            icon: const Icon(Icons.search)),
                        PopupMenuButton(
                            position: PopupMenuPosition.under,
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      height: 30.h,
                                      onTap: () =>
                                          FirebaseController().logOut(context),
                                      child: const Text("Logout"))
                                ])
                      ],
                      expandedHeight: 120.h,
                      bottom: TabBar(
                          tabs: tabs,
                          unselectedLabelColor:
                              AppColors.whiteColor.withOpacity(0.7),
                          labelColor: AppColors.whiteColor)),
                ];
              },
              body: const TabBarView(children: [
                CommunityViewTab(),
                ChatViewTab(),
                StatusViewTab(),
                CallViewsTab()
              ])),
        ));
  }
}

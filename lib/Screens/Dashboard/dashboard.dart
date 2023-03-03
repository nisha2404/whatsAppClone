import 'dart:async';

import 'package:chatting_app/Screens/Dashboard/Chats/chat_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/Settings/settings.dart';
import 'package:chatting_app/Screens/Dashboard/all_contacts_view.dart';
import 'package:chatting_app/Screens/Dashboard/calls/call_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/community/community_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/status/status_view_tab.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:firebase_database/firebase_database.dart';
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

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  final _firebase = FirebaseDatabase.instance;
  final dbController = FirebaseController();
  List<Widget> tabs = [
    Tab(
      icon: Image.asset(AppIcons.communityIcon,
          height: 18.sp, color: AppColors.whiteColor),
    ),
    const Tab(child: Text("Chats", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Status", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Calls", style: GetTextTheme.sf16_bold)),
  ];

  late Timer timer;

  List<PopupMenuItem> popupOptions() {
    return [
      PopupMenuItem(onTap: () => {}, child: const Text("New Group")),
      PopupMenuItem(onTap: () => {}, child: const Text("New Broadcast")),
      PopupMenuItem(onTap: () => {}, child: const Text("Linked Devices")),
      PopupMenuItem(onTap: () => {}, child: const Text("Starred messages")),
      PopupMenuItem(onTap: () => {}, child: const Text("Payments")),
      PopupMenuItem(
          onTap: () => {AppServices.pushTo(const SettingsView(), context)},
          child: const Text("Settings")),
      PopupMenuItem(
          onTap: () => FirebaseController().logOut(context),
          child: const Text("Logout")),
    ];
  }

  @override
  void initState() {
    super.initState();
    final path = _firebase.ref("chatRoom");
    path.onChildAdded.listen((event) {
      dbController.setNewChatRoom(event, context);
    });
    path.onChildChanged
        .listen((event) => dbController.setLastMsg(event, context));
    timer =
        Timer.periodic(const Duration(minutes: 1), (timer) => setState(() {}));
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }

  void setStatus(bool status) async {
    status == true
        ? await database
            .ref()
            .child("users")
            .child(auth.currentUser!.uid)
            .update({"isActive": status})
        : await database
            .ref()
            .child("users")
            .child(auth.currentUser!.uid)
            .update({
            "isActive": status,
            "lastSeen": DateTime.now().millisecondsSinceEpoch
          });
  }

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
                            onPressed: () => AppServices.pushTo(
                                const SettingsView(), context),
                            splashRadius: 20.r,
                            icon: const Icon(Icons.camera_alt_outlined)),
                        IconButton(
                            onPressed: () {},
                            splashRadius: 20.r,
                            icon: const Icon(Icons.search)),
                        PopupMenuButton(
                            position: PopupMenuPosition.over,
                            itemBuilder: (context) => popupOptions())
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

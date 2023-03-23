import 'dart:async';

import 'package:chatting_app/Screens/Dashboard/Chats/chat_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/all_contacts_view.dart';
import 'package:chatting_app/Screens/Dashboard/calls/call_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/community/community_view_tab.dart';
import 'package:chatting_app/Screens/Dashboard/status/status_view_tab.dart';
import 'package:chatting_app/controllers/chat_handler.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  late StreamSubscription<DatabaseEvent> _userSubscription;

  List<Widget> tabs = [
    Tab(
      icon: Image.asset(AppIcons.communityIcon,
          height: 18.sp, color: AppColors.whiteColor),
    ),
    const Tab(child: Text("Chats", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Status", style: GetTextTheme.sf16_bold)),
    const Tab(child: Text("Calls", style: GetTextTheme.sf16_bold)),
  ];

  List<PopupMenuItem> popupOptions() {
    return [
      PopupMenuItem(
        onTap: () => {},
        value: "group",
        child: const Text("New Group"),
      ),
      // PopupMenuItem( child: const Text("New Broadcast")),
      // PopupMenuItem( child: const Text("Linked Devices")),
      // PopupMenuItem( child: const Text("Starred messages")),
      // PopupMenuItem( child: const Text("Payments")),
      const PopupMenuItem(value: "settings", child: Text("Settings")),
      const PopupMenuItem(value: "logout", child: Text("Logout")),
    ];
  }

  @override
  void initState() {
    super.initState();
    getSession();
  }

  getSession() async {
    // final db = Provider.of<AppDataController>(context, listen: false);
    // if (!await rebuild()) return;
    // db.setLoader(true);
    final path = _firebase.ref("chatRoom");
    // .equalTo(auth.currentUser!.uid);
    final path2 = database.ref("users");
    path.onChildAdded.listen((event) async {
      await ChatHandler().onChatRoomAdded(context, event);
    });
    path.onChildChanged.listen((event) {
      ChatHandler().setData(event, context);
    });
    _userSubscription = path2.onChildChanged.listen((event) {
      ChatHandler().setUserData(event, context);
    });
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
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

  @override
  void dispose() {
    super.dispose();
    _userSubscription.cancel();
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
        backgroundColor: AppColors.whiteColor,
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                AppServices.pushTo(const AllContactsView(), context),
            backgroundColor: AppColors.primaryColor,
            child: Image.asset(AppGiffs.chatBubbleGiff,
                height: 35.sp, color: AppColors.whiteColor)),
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
                            onPressed: () => {},
                            splashRadius: 20.r,
                            icon: const Icon(Icons.camera_alt_outlined)),
                        IconButton(
                            onPressed: () {},
                            splashRadius: 20.r,
                            icon: const Icon(Icons.search)),
                        PopupMenuButton(
                            onSelected: (value) =>
                                AppServices.getPopUpRoute(value, context),
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

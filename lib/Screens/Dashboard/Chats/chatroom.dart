// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/chat_handler.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../helpers/base_getters.dart';
import '../../../helpers/icons_and_images.dart';
import '../../../helpers/style_sheet.dart';

class ChatRoom extends StatefulWidget {
  UserModel user;
  ChatRoom({super.key, required this.user});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _msgCtrl = TextEditingController();
  final _firebase = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    getStuff();
  }

  getStuff() {
    FirebaseController().resetMessages(context);
    _firebase
        .ref(
            "chatRoom/${FirebaseController().createChatRoomId(widget.user.uid)}/chats")
        .onChildAdded
        .listen((event) {
      ChatHandler().onMsgSend(context, event);
    });
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  bool emojiShowing = false;

  _onEmojiSelected(Emoji emoji) {
    _msgCtrl
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msgCtrl.text.length));
  }

  _onBackspacePressed() {
    _msgCtrl
      ..text = _msgCtrl.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msgCtrl.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chats = db.getIndividualChats;
    return WillPopScope(
      onWillPop: () {
        if (emojiShowing) {
          setState(() {
            emojiShowing = false;
          });
          return Future.value(false);
        } else {
          () => AppServices.popView(context);
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () => {
          setState(() => emojiShowing = false),
          AppServices.keyboardUnfocus(context)
        },
        child: Scaffold(
          backgroundColor: AppColors.grey100,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.whiteColor,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    constraints:
                        BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
                    onPressed: () => AppServices.popView(context),
                    icon: const Icon(Icons.arrow_back)),
                Container(
                    height: 36.sp,
                    width: 36.sp,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(400.r),
                      child: Image.asset(AppImages.avatarPlaceholder,
                          fit: BoxFit.cover),
                    )),
                AppServices.addWidth(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.phoneNumber,
                          style: GetTextTheme.sf16_bold),
                      Text(DateTime.now().toString(),
                          style: GetTextTheme.sf12_regular),
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
                  onPressed: () {},
                  splashRadius: 20.r,
                  icon: const Icon(Icons.call)),
              IconButton(
                  onPressed: () {},
                  splashRadius: 20.r,
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Card(
              //   color: AppColors.orange20,
              //   margin: EdgeInsets.symmetric(horizontal: 25.sp, vertical: 20.sp),
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15.r),
              //       side: BorderSide.none),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
              //     child: const Text(
              //         "Messages are end-to-end encrypted. No one outside of this chat, not even ${AppConfig.appName}, can read or listen to them.",
              //         textAlign: TextAlign.center,
              //         style: GetTextTheme.sf12_regular),
              //   ),
              // ),
              AppServices.addHeight(10.h),
              Expanded(
                child: SizedBox(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.sp),
                  child: ListView.separated(
                    controller: _controller,
                    padding: EdgeInsets.symmetric(horizontal: 5.sp),
                    itemCount: chats.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) => Row(
                      mainAxisAlignment: FirebaseController().isSender(chats[i])
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          constraints: BoxConstraints(
                              maxWidth:
                                  AppServices.getScreenWidth(context) - 50.w),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: AppColors.grey150,
                                    spreadRadius: 0)
                              ],
                              color: FirebaseController().isSender(chats[i])
                                  ? AppColors.orange40
                                  : AppColors.whiteColor,
                              borderRadius: FirebaseController()
                                      .isSender(chats[i])
                                  ? BorderRadius.circular(10.r).copyWith(
                                      bottomRight: const Radius.circular(0))
                                  : BorderRadius.circular(10.r).copyWith(
                                      bottomLeft: const Radius.circular(0))),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        AppServices.getScreenWidth(context) -
                                            90.w),
                                child: Text(chats[i].msg,
                                    style: GetTextTheme.sf16_regular),
                              ),
                              AppServices.addWidth(7.w),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(db.getTimeFormat(chats[i].sendAt)),
                                  AppServices.addWidth(5),
                                  Icon(Icons.done_all,
                                      size: 18.sp, color: AppColors.blueColor)
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    separatorBuilder: (BuildContext context, int index) =>
                        AppServices.addHeight(5.h),
                  ),
                )),
              ),
              // AppServices.addHeight(20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp)
                    .copyWith(top: 10.sp, bottom: 10.sp),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(30.r)),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                constraints: BoxConstraints(
                                    minHeight: 20.sp, minWidth: 20.sp),
                                splashRadius: 20.r,
                                onPressed: () {
                                  AppServices.keyboardUnfocus(context);
                                  setState(() {
                                    emojiShowing = !emojiShowing;
                                  });
                                },
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: AppColors.grey150,
                                ),
                              ),
                            ),
                            AppServices.addWidth(2.w),
                            Expanded(
                                child: TextField(
                              onTap: () => setState(() => emojiShowing = false),
                              controller: _msgCtrl,
                              decoration: const InputDecoration(
                                  hintText: "Message",
                                  border: InputBorder.none),
                              keyboardType: TextInputType.text,
                            )),
                            IconButton(
                                constraints: BoxConstraints(
                                    minHeight: 20.sp, minWidth: 20.sp),
                                splashRadius: 20.r,
                                onPressed: () {},
                                icon: const Icon(Icons.link,
                                    color: AppColors.grey150)),
                            IconButton(
                                constraints: BoxConstraints(
                                    minHeight: 20.sp, minWidth: 20.sp),
                                splashRadius: 20.r,
                                onPressed: () {},
                                icon: const Icon(Icons.currency_rupee_rounded,
                                    color: AppColors.grey150)),
                            IconButton(
                                constraints: BoxConstraints(
                                    minHeight: 20.sp, minWidth: 20.sp),
                                splashRadius: 20.r,
                                onPressed: () {},
                                icon: const Icon(Icons.camera_alt,
                                    color: AppColors.grey150)),
                          ],
                        ),
                      ),
                    ),
                    AppServices.addWidth(5.w),
                    Container(
                      height: 45.sp,
                      width: 45.sp,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor),
                      child: IconButton(
                          constraints:
                              BoxConstraints(minHeight: 20.r, minWidth: 20.r),
                          splashRadius: 20.r,
                          onPressed: () async {
                            await FirebaseController().createChatRoom(
                              {
                                "sender": db.getcurrentUid,
                                "users": [db.getcurrentUid, widget.user.uid],
                                "message": _msgCtrl.text,
                                "sendAt": DateTime.now().toIso8601String(),
                                "seen": false
                              },
                              widget.user.uid,
                            );
                            _msgCtrl.clear();
                            _scrollDown();
                          },
                          icon: const Icon(Icons.send,
                              color: AppColors.whiteColor)),
                    )
                  ],
                ),
              ),
              Offstage(
                offstage: !emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                      onEmojiSelected: (category, Emoji emoji) {
                        _onEmojiSelected(emoji);
                      },
                      onBackspacePressed: _onBackspacePressed,
                      config: Config(
                          columns: 7,
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          initCategory: Category.RECENT,
                          bgColor: const Color(0xFFF2F2F2),
                          indicatorColor: Colors.blue,
                          iconColor: Colors.grey,
                          iconColorSelected: Colors.blue,
                          backspaceColor: Colors.blue,
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL)),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}

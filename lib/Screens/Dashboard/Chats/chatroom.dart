// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:chatting_app/Screens/Dashboard/Chats/components/image_message_tile.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/image_with_caption_msgtile.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/text_message_tile.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/chat_handler.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    getStuff();
  }

  getStuff() async {
    // final db = Provider.of<AppDataController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add Your Code here.
      FirebaseController().resetMessages(context);
    });
    database
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

  lastSeenMessage() {
    DateTime now = DateTime.now();
    Duration differenceDuration = now
        .difference(DateTime.fromMillisecondsSinceEpoch(widget.user.lastSeen));
    String finalMessage = differenceDuration.inSeconds > 59
        ? differenceDuration.inMinutes > 59
            ? differenceDuration.inDays > 23
                ? "${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : "days"}"
                : "${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? "hour" : "hours"}"
            : "${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? "minute" : "minutes"}"
        : "few Moments";

    return finalMessage;
  }

  XFile? image;
  CroppedFile? croppedImg;
  bool isUploadImage = false;
  String imageUrl = "";

  final ImagePicker _picker = ImagePicker();

  String msgType = "text";
  bool isShowStackContainer = false;

  bool showDeleteButton = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final chats = db.getIndividualChats;
    FirebaseController().msgIsSeen(chats, widget.user.uid);
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
                      Text(
                          widget.user.isActive == true
                              ? "Online"
                              : "${lastSeenMessage()} ago",
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
              child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                        itemBuilder: (context, i) {
                          bool isShowDateCard = (i == 0) ||
                              ((i == chats.length - 1) &&
                                  (chats[i].sendAt.day >
                                      chats[i - 1].sendAt.day)) ||
                              (chats[i].sendAt.day > chats[i - 1].sendAt.day &&
                                  chats[i].sendAt.day <=
                                      chats[i + 1].sendAt.day);
                          return Column(
                            children: [
                              isShowDateCard
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.sp, vertical: 5.sp),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(10.r)),
                                      child: Text(DateFormat.yMMMd()
                                          .format(chats[i].sendAt)))
                                  : const SizedBox(),
                              chats[i].msgType == "image"
                                  ? GestureDetector(
                                      onLongPress: () => setState(
                                          () => showDeleteButton = true),
                                      child: ImageMessageTile(
                                          chat: chats[i], controller: db),
                                    )
                                  : chats[i].msgType == "imageWithText"
                                      ? ImageWithCaptionMsgTile(
                                          chat: chats[i], controller: db)
                                      : TextMessageTile(
                                          chat: chats[i], controller: db)
                            ],
                          );
                        },
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
                                  onChanged: (v) => croppedImg != null
                                      ? setState(
                                          () => msgType = "image",
                                        )
                                      : setState(() => msgType = "text"),
                                  onTap: () =>
                                      setState(() => emojiShowing = false),
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
                                    onPressed: () => onImagePick(),
                                    icon: const Icon(Icons.link,
                                        color: AppColors.grey150)),
                                IconButton(
                                    constraints: BoxConstraints(
                                        minHeight: 20.sp, minWidth: 20.sp),
                                    splashRadius: 20.r,
                                    onPressed: () {},
                                    icon: const Icon(
                                        Icons.currency_rupee_rounded,
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
                              constraints: BoxConstraints(
                                  minHeight: 20.r, minWidth: 20.r),
                              splashRadius: 20.r,
                              onPressed: () async {
                                msgType == "text"
                                    ? await FirebaseController().createChatRoom(
                                        {
                                          "sender": auth.currentUser!.uid,
                                          "users": [
                                            auth.currentUser!.uid,
                                            widget.user.uid
                                          ],
                                          "message": _msgCtrl.text,
                                          "type": "text",
                                          "sendAt":
                                              DateTime.now().toIso8601String(),
                                          "seen": false,
                                        },
                                        widget.user.uid,
                                      )
                                    : await uploadImage();
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
              ),
              croppedImg != null && isShowStackContainer == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 70.sp),
                      padding: EdgeInsets.all(40.sp),
                      height: AppServices.getScreenHeight(context),
                      width: AppServices.getScreenWidth(context),
                      decoration: const BoxDecoration(color: AppColors.grey100),
                      child: isUploadImage
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : Image.file(
                              File(croppedImg!.path),
                              height: 300.sp,
                              width: 150.sp,
                            ),
                    )
                  : const SizedBox()
            ],
          )),
        ),
      ),
    );
  }

  onImagePick() async {
    var value = await _picker.pickImage(source: ImageSource.gallery);
    if (value != null) {
      await cropImage(value);
    } else {
      null;
    }
  }

  Future<void> cropImage(XFile img) async {
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: img.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image Cropper',
              toolbarColor: AppColors.primaryColor,
              toolbarWidgetColor: AppColors.whiteColor,
              initAspectRatio: CropAspectRatioPreset.square,
              hideBottomControls: false,
              lockAspectRatio: false),
          IOSUiSettings(title: "Image Cropper")
        ]);

    if (croppedImage != null) {
      setState(() {
        isShowStackContainer = true;
        croppedImg = croppedImage;
        msgType = "image";
      });
    } else {
      null;
    }
  }

  uploadImage() async {
    setState(() {
      isUploadImage = true;
    });
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance
        .ref()
        .child('images')
        .child("chatImages")
        .child(uniqueFileName);

    try {
      await referenceRoot.putFile(File(croppedImg!.path));
      imageUrl = await referenceRoot.getDownloadURL();
      await FirebaseController().createChatRoom({
        "sender": auth.currentUser!.uid,
        "users": [auth.currentUser!.uid, widget.user.uid],
        "message": _msgCtrl.text.isNotEmpty
            ? "${imageUrl}__${_msgCtrl.text}"
            : imageUrl,
        "type": _msgCtrl.text.isNotEmpty ? "imageWithText" : "image",
        "sendAt": DateTime.now().toIso8601String(),
        "seen": false,
      }, widget.user.uid);

      setState(() {
        isShowStackContainer = false;
        isUploadImage = false;
        croppedImg = null;
      });
    } catch (e) {
      setState(() => isUploadImage = false);
      print(e);
    }
  }

  onDeletePress() {}
}

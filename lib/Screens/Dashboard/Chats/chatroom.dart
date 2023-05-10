// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:chatting_app/Screens/Dashboard/Chats/components/chatRoom_appbar.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/emoji_picker.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/msg_selected_chatRoom_appbar.dart';
import 'package:chatting_app/Screens/Dashboard/Chats/components/msg_textField.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../controllers/app_data_controller.dart';
import '../../../helpers/base_getters.dart';
import '../../../helpers/style_sheet.dart';
import 'components/image_message_tile.dart';
import 'components/image_with_caption_msgtile.dart';
import 'components/text_message_tile.dart';

class ChatRoom extends StatefulWidget {
  UserModel user;

  ChatRoom({super.key, required this.user});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  dynamic _chatRoom;

  final _msgCtrl = TextEditingController();
  final ScrollController _controller = ScrollController();

  late StreamSubscription<DatabaseEvent> _subscription;
  late StreamSubscription<DatabaseEvent> _updateSubscription;
  @override
  void initState() {
    super.initState();

    initialize();
  }

  initialize() async {
    var room = FirebaseController()
        .isChatRoomAvailable(context, widget.user.uid)
        .where((element) => element.isGroupMsg == false)
        .toList();
    if (room.isNotEmpty) {
      setState(() {
        _chatRoom = room.first;
      });
    } else {
      null;
    }
  }

  DatabaseReference getUrl() {
    final path = database.ref("chatRoom/${_chatRoom.chatroomId}/chats");
    return path;
  }

  void _scrollDown() {
    if (_controller.hasClients) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
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

  XFile? image;
  CroppedFile? croppedImg;
  bool isUploadImage = false;
  String imageUrl = "";

  final ImagePicker _picker = ImagePicker();

  String msgType = "text";
  bool isShowStackContainer = false;

  bool showDeleteButton = false;

  bool isDataUploaded = false;

  List<ChatModel> selectedChats = [];

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    initialize();
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
          appBar: selectedChats.isEmpty
              ? chatRoomAppBar(widget.user, context)
              : msgSelectedChatRoomAppBar(
                  context,
                  selectedChats,
                  () => setState(() => selectedChats = []),
                  _chatRoom.chatroomId),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppImages.doodles,
                  color: AppColors.blackColor.withOpacity(0.08),
                  fit: BoxFit.cover),
              SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppServices.addHeight(10.h),
                  _chatRoom == null
                      ? const SizedBox()
                      : (croppedImg != null && isShowStackContainer == true
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 70.sp),
                                padding: EdgeInsets.all(40.sp),
                                height: AppServices.getScreenHeight(context),
                                width: AppServices.getScreenWidth(context),
                                decoration: const BoxDecoration(
                                    color: AppColors.grey100),
                                child: isUploadImage
                                    ? const Center(
                                        child: CircularProgressIndicator
                                            .adaptive())
                                    : Image.file(
                                        File(croppedImg!.path),
                                        height: 300.sp,
                                        width: 150.sp,
                                      ),
                              ),
                            )
                          : Expanded(
                              child: SizedBox(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.sp),
                                      child: FirebaseAnimatedList(
                                          controller: _controller,
                                          query: getUrl(),
                                          itemBuilder: (context, snapshot,
                                              animation, i) {
                                            final chats = snapshot.value
                                                as Map<Object?, Object?>;
                                            final msgType =
                                                chats['type'].toString();
                                            final sendAt = DateTime.parse(
                                                chats['sendAt'].toString());

                                            FirebaseController().markAsSeen(
                                                _chatRoom.chatroomId,
                                                ChatModel.fromChat(chats,
                                                    snapshot.key.toString()));

                                            return Column(
                                              children: [
                                                msgType == "image"
                                                    ? GestureDetector(
                                                        onLongPress: () => {},
                                                        child: ImageMessageTile(
                                                            chat: ChatModel
                                                                .fromChat(
                                                                    chats,
                                                                    snapshot.key
                                                                        .toString()),
                                                            controller: db),
                                                      )
                                                    : msgType == "imageWithText"
                                                        ? ImageWithCaptionMsgTile(
                                                            chat: ChatModel
                                                                .fromChat(
                                                                    chats,
                                                                    snapshot.key
                                                                        .toString()),
                                                            controller: db)
                                                        : InkWell(
                                                            onLongPress: () {
                                                              onLongPress(
                                                                  snapshot.key
                                                                      .toString(),
                                                                  chats);
                                                            },
                                                            onTap: () {
                                                              onTap(
                                                                  snapshot.key
                                                                      .toString(),
                                                                  chats);
                                                            },
                                                            child: TextMessageTile(
                                                                user: widget
                                                                    .user,
                                                                chat: ChatModel
                                                                    .fromChat(
                                                                        chats,
                                                                        snapshot.key
                                                                            .toString()),
                                                                controller: db,
                                                                isSelected: selectedChats
                                                                    .any((element) =>
                                                                        element
                                                                            .msgId ==
                                                                        snapshot
                                                                            .key
                                                                            .toString())))
                                              ],
                                            );
                                          }))),
                            )),
                  MsgTextField(
                      onLinkBtnPressed: () => onImagePick(),
                      onEmojiPressed: () => {
                            AppServices.keyboardUnfocus(context),
                            setState(() {
                              emojiShowing = !emojiShowing;
                            })
                          },
                      onSendBtnPressed: () async {
                        msgType == "text"
                            ? {
                                await FirebaseController().createChatRoom({
                                  "status": MessageStatus.sent.name,
                                  "sender": auth.currentUser!.uid,
                                  "sendAt": DateTime.now().toIso8601String(),
                                  "message": _msgCtrl.text,
                                  "type": "text"
                                }, widget.user.uid, context)
                              }
                            : await uploadImage();
                        _msgCtrl.clear();
                        _scrollDown();
                      },
                      onChange: (v) => croppedImg != null
                          ? setState(
                              () => msgType = "image",
                            )
                          : setState(() => msgType = "text"),
                      msgCtrl: _msgCtrl,
                      onTextFieldTap: () =>
                          setState(() => emojiShowing = false)),
                  AppEmojiPicker(
                      offstage: !emojiShowing,
                      onEmojiSelected: (category, Emoji emoji) =>
                          _onEmojiSelected(emoji),
                      onBackspacePressed: () => _onBackspacePressed())
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  onLongPress(String id, Map<Object?, Object?> chats) {
    if (selectedChats.isEmpty) {
      selectedChats.any((element) => element.msgId == id)
          ? null
          : selectedChats.add(ChatModel.fromChat(chats, id));
    } else {
      null;
    }
    setState(() {});
  }

  onTap(String id, Map<Object?, Object?> chats) {
    if (selectedChats.isEmpty) {
      null;
    } else {
      selectedChats.any((element) => element.msgId == id)
          ? selectedChats.removeWhere((element) => element.msgId == id)
          : selectedChats.add(ChatModel.fromChat(chats, id));
    }

    setState(() {});
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
        "status": MessageStatus.sent.name,
        "sender": auth.currentUser!.uid,
        "message": _msgCtrl.text.isNotEmpty
            ? "${imageUrl}__${_msgCtrl.text}"
            : imageUrl,
        "type": _msgCtrl.text.isNotEmpty ? "imageWithText" : "image",
        "sendAt": DateTime.now().toIso8601String(),
      }, widget.user.uid, context);

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
}

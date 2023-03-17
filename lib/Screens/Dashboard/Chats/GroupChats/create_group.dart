// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/shimmers/profile_img_shimmer.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../components/shimmers/chat_image_shimmer.dart';
import '../../../../models/app_models.dart';
import '../../dashboard.dart';

class CreateGroupView extends StatefulWidget {
  List<UserModel> participants;
  CreateGroupView({super.key, required this.participants});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final TextEditingController _nameController = TextEditingController();
  bool emojiShowing = false;

  _onEmojiSelected(Emoji emoji) {
    _nameController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length));
  }

  _onBackspacePressed() {
    _nameController
      ..text = _nameController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length));
  }

  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  bool isUploadImage = false;

  CroppedFile? croppedProfileImg;
  XFile? profileImage;

  String imageUrl = "";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (emojiShowing) {
          setState(() {
            emojiShowing = false;
          });
          return Future.value(false);
        } else {
          () => SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () => {
          setState(() => emojiShowing = false),
          AppServices.keyboardUnfocus(context)
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.whiteColor,
              foregroundColor: AppColors.blackColor,
              title: Text("New Group",
                  style: GetTextTheme.sf20_bold
                      .copyWith(color: AppColors.primaryColor)),
              centerTitle: true),
          body: SafeArea(
              child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                        "Please provide your group subject and a group profile photo",
                        textAlign: TextAlign.center,
                        style: GetTextTheme.sf14_medium
                            .copyWith(color: AppColors.grey150)),
                    AppServices.addHeight(40.h),
                    isUploadImage
                        ? const CircularProgressIndicator()
                        : imageUrl == ""
                            ? GestureDetector(
                                onTap: () => onImagePick(),
                                child: Container(
                                  padding: EdgeInsets.all(35.sp),
                                  height: 120.sp,
                                  width: 120.sp,
                                  decoration: const BoxDecoration(
                                      color: AppColors.grey100,
                                      shape: BoxShape.circle),
                                  child: Image.asset(AppIcons.cameraIcon,
                                      fit: BoxFit.contain,
                                      color: AppColors.whiteColor),
                                ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(1000.r),
                                child: CachedNetworkImage(
                                    height: 120.sp,
                                    width: 120.sp,
                                    imageUrl: imageUrl,
                                    placeholder: (context, url) =>
                                        ProfileImageShimmer(
                                            height: 120, width: 120)),
                              ),
                    AppServices.addHeight(20.h),
                    Row(
                      children: [
                        Expanded(
                          child: UnderlineInputBorderTextField(
                            ontap: () => setState(() => emojiShowing = false),
                            controller: _nameController,
                            hint: "Type group subject here...",
                            isDense: true,
                            horizontalpadding: 2,
                            verticalpadding: 8.sp,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: () {
                              AppServices.keyboardUnfocus(context);
                              setState(() {
                                emojiShowing = !emojiShowing;
                              });
                            },
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: AppColors.grey150,
                              size: 32.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppServices.addHeight(10.h),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Participants : ${widget.participants.length}",
                            style: GetTextTheme.sf14_regular.copyWith(
                                color: AppColors.blackColor.withOpacity(0.5))),
                        AppServices.addHeight(10.h),
                        SizedBox(
                          height: 92.h,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ListView.builder(
                                itemCount: widget.participants.length,
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
                                              child: widget.participants[i]
                                                          .image ==
                                                      ""
                                                  ? Image.asset(
                                                      AppImages
                                                          .avatarPlaceholder,
                                                      fit: BoxFit.cover)
                                                  : CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      imageUrl: widget
                                                          .participants[i]
                                                          .image,
                                                      placeholder: (context,
                                                              url) =>
                                                          ChatImageShimmer(
                                                              height: 50.sp,
                                                              width: 50.sp),
                                                    ),
                                            ),
                                          ),
                                          AppServices.addHeight(3.h),
                                          Text(widget.participants[i].userName,
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
                      ],
                    ),
                    AppServices.addHeight(80.h),
                    isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Row(
                            children: [
                              ExpandedButton(
                                  btnName: "Continue",
                                  onPress: () => onContinue())
                            ],
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
              hideBottomControls: true,
              lockAspectRatio: true),
          IOSUiSettings(title: "Image Cropper")
        ]);

    if (croppedImage != null) {
      setState(() => croppedProfileImg = croppedImage);
      await uploadImage();
    } else {
      null;
    }
  }

  uploadImage() async {
    setState(() => isUploadImage = true);
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance
        .ref()
        .child('images')
        .child("groupProfileImage")
        .child(uniqueFileName);

    try {
      await referenceRoot.putFile(File(croppedProfileImg!.path));
      imageUrl = await referenceRoot.getDownloadURL();
      setState(() => isUploadImage = false);
    } catch (e) {
      setState(() => isUploadImage = false);
      print(e);
    }
  }

  onContinue() async {
    setState(() => isLoading = true);
    await FirebaseController().createGroupChatRoom({
      "members": [
        auth.currentUser!.uid,
        ...widget.participants.map((e) => e.uid).toList()
      ],
      "isGroup": true,
      "groupName": _nameController.text,
      "admin": auth.currentUser!.uid,
      "groupImg": imageUrl,
      "createdAt": DateTime.now().toIso8601String()
    });
    setState(() => isLoading = false);
    AppServices.pushAndRemove(const Dashboard(), context);
  }
}

// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/dashboard.dart';
import 'package:chatting_app/app_config.dart';
import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/help_popup_button.dart';
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

class AddProfileInfo extends StatefulWidget {
  const AddProfileInfo({super.key});

  @override
  State<AddProfileInfo> createState() => _AddProfileInfoState();
}

class _AddProfileInfoState extends State<AddProfileInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
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
            title: Text("Profile info",
                style: GetTextTheme.sf20_bold
                    .copyWith(color: AppColors.primaryColor)),
            centerTitle: true,
            actions: const [HelpPopUpMenuButton()],
          ),
          body: SafeArea(
              child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                        "Please provide your name and an optional profile photo",
                        textAlign: TextAlign.center,
                        style: GetTextTheme.sf14_medium
                            .copyWith(color: AppColors.grey150)),
                    AppServices.addHeight(40.h),
                    isUploadImage
                        ? const CircularProgressIndicator()
                        : imageUrl == ""
                            ? GestureDetector(
                                onTap: () => onImagePick(),
                                child: const CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      AssetImage(AppImages.avatarPlaceholder),
                                ),
                              )
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
                            hint: "Enter your name",
                            maxlength: 20,
                            isDense: true,
                            horizontalpadding: 0,
                            verticalpadding: 0,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "This is not your username or pin. This name will be visible to your ${AppConfig.appName} contacts.",
                          style: GetTextTheme.sf10_regular
                              .copyWith(color: AppColors.grey150)),
                    ),
                    AppServices.addHeight(40.h),
                    UnderlineInputBorderTextField(
                      ontap: () => setState(() => emojiShowing = false),
                      controller: _aboutController,
                      hint: "Enter something about yourself",
                      isDense: true,
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
    Reference referenceRoot =
        FirebaseStorage.instance.ref().child('images').child(uniqueFileName);

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
    Map<String, dynamic> data = {
      "isActive": true,
      "groupId": [],
      "lastSeen": DateTime.now().millisecondsSinceEpoch,
      "uid": auth.currentUser!.uid,
      "userName": _nameController.text.trim(),
      "profileImg": imageUrl == "" ? "" : imageUrl,
      "about": _aboutController.text.isEmpty
          ? "Hey! there I am using ${AppConfig.appName}"
          : _aboutController.text.trim(),
      "phoneNumber": auth.currentUser!.phoneNumber
    };
    await FirebaseController().addUserProfile(data, context);
    setState(() => isLoading = false);
    AppServices.pushAndRemove(const Dashboard(), context);
  }
}

// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:chatting_app/app_config.dart';
import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/help_popup_button.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:emoji_picker_2/emoji_picker_2.dart';
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

  bool showEmojis = false;

  CroppedFile? croppedProfileImg;
  XFile? profileImage;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (showEmojis) {
          setState(() {
            showEmojis = false;
          });
          return Future.value(false);
        } else {
          () => SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () => {
          setState(() => showEmojis = false),
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
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(AppImages.avatarPlaceholder),
                    ),
                    AppServices.addHeight(20.h),
                    Row(
                      children: [
                        Expanded(
                          child: UnderlineInputBorderTextField(
                            ontap: () => setState(() => showEmojis = false),
                            controller: _nameController,
                            hint: "Enter your name",
                            maxlength: 20,
                            isDense: true,
                            horizontalpadding: 0,
                            verticalpadding: 0,
                          ),
                        ),
                        IconButton(
                            constraints: BoxConstraints(
                                minHeight: 20.sp, minWidth: 20.sp),
                            splashRadius: 1.r,
                            onPressed: () => {
                                  AppServices.keyboardUnfocus(context),
                                  Future.delayed(
                                      const Duration(milliseconds: 220),
                                      () => setState(
                                          () => showEmojis = !showEmojis))
                                },
                            icon: Icon(Icons.emoji_emotions_outlined,
                                color: AppColors.grey150, size: 32.sp)),
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
                      ontap: () => setState(() => showEmojis = false),
                      controller: _aboutController,
                      hint: "Enter something about yourself",
                      isDense: true,
                    ),
                    AppServices.addHeight(80.h),
                    Row(
                      children: [
                        ExpandedButton(btnName: "Continue", onPress: () => {})
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                  bottom: 0,
                  child: showEmojis ? emojiSelect() : const SizedBox())
            ],
          )),
        ),
      ),
    );
  }

  Widget emojiSelect() {
    return EmojiPicker2(
      onEmojiSelected: (emoji, category) => {
        setState(
            () => _nameController.text = _nameController.text + emoji.emoji)
      },
      rows: 4,
      columns: 7,
    );
  }
}

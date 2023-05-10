// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/Settings/views/profile/update_userabout_dialog.dart';
import 'package:chatting_app/Screens/Dashboard/Settings/views/profile/update_username_dialog.dart';
import 'package:chatting_app/app_config.dart';
import 'package:chatting_app/components/shimmers/profile_img_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();

  CroppedFile? croppedProfileImg;
  XFile? profileImage;

  String imgUrl = "";

  bool isUploadImage = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDataController>(context);
    final user = db.getcurrentUser;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Profile", style: GetTextTheme.sf18_bold),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: user.uid,
                  child: Container(
                    height: 150.sp,
                    width: 150.sp,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUploadImage
                            ? AppColors.grey100
                            : AppColors.whiteColor),
                    child: isUploadImage
                        ? const CircularProgressIndicator.adaptive()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(1000.r),
                            child: imgUrl == ""
                                ? (user.image == ""
                                    ? Image.asset(AppImages.avatarPlaceholder)
                                    : CachedNetworkImage(
                                        imageUrl: user.image,
                                        placeholder: (context, url) =>
                                            ProfileImageShimmer(
                                                height: 150, width: 150)))
                                : CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    placeholder: (context, url) =>
                                        ProfileImageShimmer(
                                            height: 150, width: 150))),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: GestureDetector(
                    onTap: () => onImagePick(user.image),
                    child: Container(
                      width: 50.sp,
                      height: 50.sp,
                      padding: EdgeInsets.all(12.sp),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Image.asset(
                        AppIcons.cameraIcon,
                        height: 30.sp,
                        width: 30.sp,
                        fit: BoxFit.contain,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
            AppServices.addHeight(30.sp),
            detail_tile(
                () => showDialog(
                    context: context,
                    builder: (context) =>
                        UpdateUsernameDialog(username: user.userName)),
                true,
                AppIcons.profileIcon,
                "Name",
                user.userName),
            AppServices.addHeight(10.sp),
            Text(
                "This is not your username or pin. This name will be visible to your ${AppConfig.appName} contacts.",
                style: GetTextTheme.sf12_regular
                    .copyWith(color: AppColors.grey150)),
            AppServices.addHeight(8.sp),
            const Divider(thickness: 1, color: AppColors.grey50),
            AppServices.addHeight(8.sp),
            detail_tile(
                () => showDialog(
                    context: context,
                    builder: (context) =>
                        UpdateuserAboutDialog(about: user.aboutUser)),
                true,
                AppIcons.infoIcon,
                "About",
                user.aboutUser),
            AppServices.addHeight(8.sp),
            const Divider(thickness: 1, color: AppColors.grey50),
            AppServices.addHeight(8.sp),
            detail_tile(
                () => {}, false, AppIcons.phoneIcon, "Phone", user.phoneNumber),
          ],
        ),
      ),
    );
  }

  Row detail_tile(Function ontap, bool isEditIcon, String leading, String title,
      String subtitle) {
    return Row(
      children: [
        Image.asset(leading, height: 20.sp, color: AppColors.grey150),
        AppServices.addWidth(20.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GetTextTheme.sf14_bold
                      .copyWith(color: AppColors.grey150)),
              AppServices.addHeight(2.sp),
              Text(subtitle, style: GetTextTheme.sf16_medium)
            ],
          ),
        ),
        isEditIcon
            ? IconButton(
                onPressed: () => ontap(),
                icon: Image.asset(AppIcons.editIcon,
                    height: 20.sp, color: AppColors.primaryColor))
            : const SizedBox()
      ],
    );
  }

  onImagePick(String imgpath) async {
    var value = await _picker.pickImage(source: ImageSource.gallery);
    if (value != null) {
      await cropImage(value, imgpath);
    } else {
      null;
    }
  }

  Future<void> cropImage(XFile img, String imgPath) async {
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
      await uploadImage(imgPath);
    } else {
      null;
    }
  }

  uploadImage(String imgPath) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    setState(() => isUploadImage = true);
    final path = database.ref("users/${auth.currentUser!.uid}");
    Reference deleteImgRef = storage.refFromURL(imgPath);
    await deleteImgRef.delete();
    String uniqueFileName = auth.currentUser!.uid;
    Reference referenceRoot =
        FirebaseStorage.instance.ref().child('images').child(uniqueFileName);

    try {
      await referenceRoot.putFile(File(croppedProfileImg!.path));
      imgUrl = await referenceRoot.getDownloadURL();
      await path.update({"profileImg": imgUrl});
      await path.get().then((v) => db.setCurrentUser(UserModel.fromUser(
          v.value as Map<Object?, Object?>, v.key.toString())));
      setState(() => isUploadImage = false);
    } on SocketException catch (e) {
      setState(() => isUploadImage = false);
      print(e);
    }
  }
}

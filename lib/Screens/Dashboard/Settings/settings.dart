import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Screens/Dashboard/Settings/views/profile/profile_view.dart';
import 'package:chatting_app/components/shimmers/profile_img_shimmer.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: GetTextTheme.sf18_bold),
        backgroundColor: AppColors.primaryColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        foregroundColor: AppColors.whiteColor,
        elevation: 0,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          Consumer<AppDataController>(builder: (context, data, child) {
            final user = data.getcurrentUser;
            return InkWell(
              onTap: () => AppServices.pushTo(const ProfileView(), context),
              child: Container(
                margin: EdgeInsets.all(15.sp),
                child: Row(
                  children: [
                    Hero(
                      tag: user.uid,
                      child: Container(
                          height: 65.sp,
                          width: 65.sp,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(400.r),
                            child: user.image == ""
                                ? Image.asset(AppImages.avatarPlaceholder,
                                    fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: user.image,
                                    placeholder: (context, url) =>
                                        ProfileImageShimmer(
                                            height: 65, width: 65)),
                          )),
                    ),
                    AppServices.addWidth(10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.userName, style: GetTextTheme.sf20_regular),
                          AppServices.addHeight(2.h),
                          Text(user.aboutUser,
                              style: GetTextTheme.sf14_regular
                                  .copyWith(color: AppColors.grey150),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                        constraints:
                            BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
                        splashRadius: 20.r,
                        onPressed: () => {},
                        icon: Icon(
                          Icons.qr_code,
                          size: 28.sp,
                          color: AppColors.primaryColor,
                        ))
                  ],
                ),
              ),
            );
          }),
          const Divider(thickness: 1, color: AppColors.grey100),
          custom_tile("Account", "Security Notifications, change number",
              AppIcons.keyIcon, () => {}),
          custom_tile("Privacy", "Block contacts, dissappearing messages",
              AppIcons.lockedIcon, () => {}),
          custom_tile("Avatar", "Create, edit, profile photo",
              AppIcons.avatarIcon, () => {}),
          custom_tile("Chats", "Theme, wallpapers, chat history",
              AppIcons.chatIcon, () => {}),
          custom_tile("Notifications", "Message, group & call tones",
              AppIcons.notificationIcon, () => {}),
          custom_tile("Storage and data", "Network usage, auto-download",
              AppIcons.dataIcon, () => {}),
          custom_tile("App language", "English(phone's language)",
              AppIcons.worldIcon, () => {}),
          custom_tile("Help", "Help centre, contact us, privacy policy",
              AppIcons.keyIcon, () => {}),
          custom_tile(
              "Invite a friend", "", AppIcons.shareWithFriendsIcon, () => {}),
        ]),
      )),
    );
  }

  ListTile custom_tile(
      String title, String subtitle, String icon, Function ontap) {
    return ListTile(
      onTap: () => ontap(),
      leading: Image.asset(icon,
          color: AppColors.grey150, height: 25.sp, width: 25.sp),
      title: Text(title, style: GetTextTheme.sf16_regular),
      subtitle: Text(subtitle,
          style: GetTextTheme.sf14_regular.copyWith(color: AppColors.grey150)),
    );
  }
}

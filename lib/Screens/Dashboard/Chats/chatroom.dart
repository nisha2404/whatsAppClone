// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../helpers/base_getters.dart';
import '../../../helpers/icons_and_images.dart';
import '../../../helpers/style_sheet.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
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
                  const Text("Receiver name", style: GetTextTheme.sf16_bold),
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
          Expanded(
            child: SizedBox(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 5.sp),
                itemCount: 2,
                shrinkWrap: true,
                itemBuilder: (context, i) => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: AppServices.getScreenWidth(context) - 50.w),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.greenColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5.r)
                              .copyWith(bottomRight: const Radius.circular(0))),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: AppServices.getScreenWidth(context) -
                                    100.w),
                            child: const Text("This is my first message",
                                style: GetTextTheme.sf16_regular),
                          ),
                          AppServices.addWidth(7.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat("hh:mm").format(
                                  DateTime.parse(DateTime.now().toString()))),
                              AppServices.addWidth(5),
                              const Icon(Icons.done_all,
                                  color: AppColors.blueColor)
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
          AppServices.addHeight(20.h),
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
                        IconButton(
                            constraints: BoxConstraints(
                                minHeight: 20.sp, minWidth: 20.sp),
                            splashRadius: 20.r,
                            onPressed: () {},
                            icon: const Icon(Icons.emoji_emotions_outlined,
                                color: AppColors.grey150)),
                        AppServices.addWidth(2.w),
                        Expanded(
                            child: TextField(
                          controller: _msgCtrl,
                          decoration: const InputDecoration(
                              hintText: "Message", border: InputBorder.none),
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
                      shape: BoxShape.circle, color: AppColors.primaryColor),
                  child: IconButton(
                      constraints:
                          BoxConstraints(minHeight: 20.r, minWidth: 20.r),
                      splashRadius: 20.r,
                      onPressed: () {
                        _msgCtrl.clear();
                      },
                      icon:
                          const Icon(Icons.send, color: AppColors.whiteColor)),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}

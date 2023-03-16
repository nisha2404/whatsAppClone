// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../helpers/base_getters.dart';
import '../../../../helpers/style_sheet.dart';

class MsgTextField extends StatelessWidget {
  Function onEmojiPressed, onLinkBtnPressed, onSendBtnPressed, onTextFieldTap;
  Function(String) onChange;
  TextEditingController msgCtrl;

  MsgTextField(
      {super.key,
      required this.onLinkBtnPressed,
      required this.onEmojiPressed,
      required this.onSendBtnPressed,
      required this.onChange,
      required this.msgCtrl,
      required this.onTextFieldTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      constraints:
                          BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
                      splashRadius: 20.r,
                      onPressed: () {
                        onEmojiPressed();
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
                    onChanged: (v) => {onChange(v)},
                    onTap: () => onTextFieldTap(),
                    controller: msgCtrl,
                    decoration: const InputDecoration(
                        hintText: "Message", border: InputBorder.none),
                    keyboardType: TextInputType.text,
                  )),
                  IconButton(
                      constraints:
                          BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
                      splashRadius: 20.r,
                      onPressed: () => {onLinkBtnPressed()},
                      icon: const Icon(Icons.link, color: AppColors.grey150)),
                  // IconButton(
                  //     constraints: BoxConstraints(
                  //         minHeight: 20.sp, minWidth: 20.sp),
                  //     splashRadius: 20.r,
                  //     onPressed: () {},
                  //     icon: const Icon(
                  //         Icons.currency_rupee_rounded,
                  //         color: AppColors.grey150)),
                  IconButton(
                      constraints:
                          BoxConstraints(minHeight: 20.sp, minWidth: 20.sp),
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
                constraints: BoxConstraints(minHeight: 20.r, minWidth: 20.r),
                splashRadius: 20.r,
                onPressed: () {
                  onSendBtnPressed();
                },
                icon: const Icon(Icons.send, color: AppColors.whiteColor)),
          )
        ],
      ),
    );
  }
}

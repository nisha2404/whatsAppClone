import 'package:chatting_app/helpers/base_getters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/style_sheet.dart';

class ChatRoomTileShimmer extends StatelessWidget {
  const ChatRoomTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: AppColors.blackColor.withOpacity(0.1),
        highlightColor: AppColors.blackColor.withOpacity(0.02),
        child: ListTile(
          leading: Container(
            height: 45.sp,
            width: 45.sp,
            decoration: const BoxDecoration(
                color: AppColors.blackColor, shape: BoxShape.circle),
          ),
          title: Row(
            children: [
              Container(
                  height: 8,
                  width: AppServices.getScreenWidth(context) * 0.6,
                  color: AppColors.blackColor),
            ],
          ),
          subtitle: Row(
            children: [
              Container(height: 8, width: 140.sp, color: AppColors.blackColor),
            ],
          ),
        ));
  }
}

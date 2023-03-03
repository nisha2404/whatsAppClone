// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/style_sheet.dart';

class ProfileImageShimmer extends StatelessWidget {
  double height;
  double width;
  ProfileImageShimmer({super.key, this.height = 45, this.width = 45});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: AppColors.blackColor.withOpacity(0.1),
        highlightColor: AppColors.blackColor.withOpacity(0.02),
        child: Container(
          height: height.sp,
          width: width.sp,
          decoration: const BoxDecoration(
              color: AppColors.primaryColor, shape: BoxShape.circle),
        ));
  }
}

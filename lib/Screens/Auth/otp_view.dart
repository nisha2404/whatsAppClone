// ignore_for_file: must_be_immutable

import 'package:chatting_app/components/help_popup_button.dart';
import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../components/expanded_button.dart';
import '../../helpers/base_getters.dart';
import '../../helpers/icons_and_images.dart';
import '../../helpers/style_sheet.dart';

class OtpScreen extends StatefulWidget {
  String phoneNumber;
  OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // otp controller
  final OtpFieldController _otpController = OtpFieldController();

  // variable to store otp in it
  String otp = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.blackColor,
        centerTitle: true,
        elevation: 0,
        title: Text("Enter OTP",
            textAlign: TextAlign.center,
            style:
                GetTextTheme.sf20_bold.copyWith(color: AppColors.primaryColor)),
        actions: const [HelpPopUpMenuButton()],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            children: [
              Text("Enter OTP send on your phone Number ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: GetTextTheme.sf16_regular),
              AppServices.addHeight(40.h),
              Image.asset(AppImages.otpVector),
              AppServices.addHeight(60.h),
              OTPTextField(
                length: 6,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                width: AppServices.getScreenWidth(context),
                fieldWidth: 35,
                keyboardType: TextInputType.number,
                fieldStyle: FieldStyle.box,
                controller: _otpController,
                onCompleted: (value) => setState(() => otp = value),
              ),
              AppServices.addHeight(40.h),
              Consumer<AppDataController>(builder: (context, data, child) {
                return data.showLoader
                    ? const CircularProgressIndicator.adaptive()
                    : Row(
                        children: [
                          ExpandedButton(
                              btnName: "Verify",
                              onPress: () => {
                                    FirebaseController().verifyCode(
                                        otp, widget.phoneNumber, context)
                                  }),
                        ],
                      );
              })
            ],
          ),
        ),
      )),
    );
  }
}

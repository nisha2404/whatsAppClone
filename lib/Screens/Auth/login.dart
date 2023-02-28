import 'package:chatting_app/app_config.dart';
import 'package:chatting_app/components/expanded_button.dart';
import 'package:chatting_app/components/help_popup_button.dart';
import 'package:chatting_app/components/underline_input_border_textfield.dart';
import 'package:chatting_app/controllers/firebase_controller.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/icons_and_images.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  final TextEditingController _phoneCodecontroller =
      TextEditingController(text: " +91");
  final TextEditingController _phoneController = TextEditingController();

  String countryName = "India";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.blackColor,
        title: Text("Enter your phone number",
            style:
                GetTextTheme.sf20_bold.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        actions: const [HelpPopUpMenuButton()],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                  "${AppConfig.appName} will need to verify your phone number.",
                  textAlign: TextAlign.center,
                  style: GetTextTheme.sf14_regular),
              AppServices.addHeight(2.h),
              GestureDetector(
                  onTap: () => {},
                  child: Text("What's my number?",
                      style: GetTextTheme.sf14_regular
                          .copyWith(color: AppColors.blueColor))),
              AppServices.addHeight(40.h),
              Image.asset(AppImages.authVector),
              AppServices.addHeight(60.h),
              GestureDetector(
                onTap: () => showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    showSearch: true,
                    onSelect: (Country country) {
                      _phoneCodecontroller.text = " +${country.phoneCode}";
                      countryName = country.name;
                      setState(() {});
                    }),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40.sp),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppColors.primaryColor))),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(countryName,
                              textAlign: TextAlign.center,
                              style: GetTextTheme.sf16_regular)),
                      Icon(Icons.arrow_drop_down_sharp, size: 30.sp)
                    ],
                  ),
                ),
              ),
              AppServices.addHeight(25.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.sp),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: UnderlineInputBorderTextField(
                          isDense: true,
                          readOnly: true,
                          controller: _phoneCodecontroller,
                        )),
                    AppServices.addWidth(10.w),
                    Expanded(
                        flex: 4,
                        child: UnderlineInputBorderTextField(
                            inputType: TextInputType.number,
                            controller: _phoneController,
                            isDense: true,
                            hint: "phone number"))
                  ],
                ),
              ),
              AppServices.addHeight(50.h),
              isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Row(
                      children: [
                        ExpandedButton(
                            btnName: "Continue", onPress: () => onContinue())
                      ],
                    )
            ],
          ),
        ),
      )),
    );
  }

  onContinue() async {
    setState(() => isLoading = true);
    bool isValidate =
        _phoneController.text.isNotEmpty && _phoneController.text.length == 10;

    if (isValidate) {
      await FirebaseController().verifyPhone(
          context, "${_phoneCodecontroller.text}${_phoneController.text}");
      _phoneController.clear();
      setState(() => isLoading = false);
    } else {
      AppServices.showToast(
          "Invalid Format! please enter a valid mobile number");
      setState(() => isLoading = false);
    }
  }
}

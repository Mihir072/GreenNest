// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:greennest/Auth/login_screen.dart';
import 'package:greennest/Helper/loader_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_button.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field.dart';
import 'package:greennest/Widget/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> forgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.showLoader(message: loadingIn);
    final response = await ApiService.forgotPassword(
      email: emailCtrl.text,
      newPassword: passwordCtrl.text,
    );
    context.hideLoader();
    if (response.statusCode == 200) {
      CustomToast.success(
        title: 'Password Reset',
        message: 'Your password has been updated',
      );
      context.pushReplacement(LoginScreen());
    } else {
      CustomToast.error(
        title: 'Reset Failed',
        message: 'Could not reset password',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.all20,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //----- Text -----//
                      CustomText(
                          text: forgotPasswordHeadline,
                          textColor: Colors.black,
                          textSize: GSizes.fontSizeLg,
                          fontWeight: FontWeight.bold),

                      //----- Text -----//
                      CustomText(
                          text: forgotPasswordSubHeadline,
                          textColor: Colors.black,
                          textSize: GSizes.fontSizeMd,
                          fontWeight: FontWeight.normal),
                      SizedBox(
                        height: GSizes.defaultSpace,
                      ),

                      //----- Text Field -----//
                      CustomTextField(
                        controller: emailCtrl,
                        hintText: email,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        textFieldImage: textFieldImageEmail,
                      ),

                      SizedBox(
                        height: GSizes.spaceBtwInputFields,
                      ),

                      //----- Text Field -----//
                      CustomTextField(
                        controller: passwordCtrl,
                        hintText: newPassword,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textFieldImage: textFieldImagePassword,
                      ),

                      SizedBox(
                        height: GSizes.spaceBtwInputFields,
                      ),

                      //----- Text -----//
                      CustomButton(
                        text: changePassword,
                        onPressed: forgotPassword,
                        backgroundColor: splashScreenColor,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

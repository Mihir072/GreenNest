// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greennest/Auth/login_screen.dart';
import 'package:greennest/Helper/loader_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Screens/home_screen.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_button.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field.dart';
import 'package:greennest/Widget/custom_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.showLoader(message: loadingIn);
    try {
      final response = await ApiService.registerUser(
        name: nameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        address: addressCtrl.text,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      context.hideLoader();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        CustomToast.success(
          title: 'Registration Complete',
          message: 'Account created successfully',
        );
        context.push(HomeScreen(
          email: data["email"],
          token: data["email"],
        ));
      } else {
        CustomToast.error(
          title: 'Registration Failed',
          message: 'Could not create account',
        );
      }
    } catch (e) {
      context.hideLoader();
      CustomToast.error(
        title: 'Error',
        message: 'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Logo/Icon section
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 28),
                // Headline
                CustomText(
                  text: registerHeadline,
                  textColor: Colors.black,
                  textSize: GSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                // Subheadline
                CustomText(
                  text: registerSubHeadline,
                  textColor: Colors.grey[600]!,
                  textSize: GSizes.fontSizeMd,
                  fontWeight: FontWeight.normal,
                ),
                SizedBox(height: 28),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field with label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: nameCtrl,
                        hintText: name,
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        textFieldImage: textFieldImageName,
                      ),
                      SizedBox(height: GSizes.spaceBtwInputFields),
                      // Email field with label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: emailCtrl,
                        hintText: email,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        textFieldImage: textFieldImageEmail,
                      ),
                      SizedBox(height: GSizes.spaceBtwInputFields),
                      // Password field with label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: passwordCtrl,
                        hintText: password,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textFieldImage: textFieldImagePassword,
                      ),
                      SizedBox(height: GSizes.spaceBtwInputFields),
                      // Address field with label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: addressCtrl,
                        hintText: address,
                        obscureText: false,
                        keyboardType: TextInputType.multiline,
                        textFieldImage: textFieldImageAddress,
                      ),
                      SizedBox(height: 32),
                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.how_to_reg_rounded,
                                  size: 22, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                registerText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.push(LoginScreen()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.green[700]!,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                size: 22,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 12),
                              Text(
                                alreadyHaveAnAccount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

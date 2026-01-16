// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:greennest/Auth/forgot_password_screen.dart';
import 'package:greennest/Auth/register_screen.dart';
import 'package:greennest/Helper/loader_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Screens/main_navigation_screen.dart';
import 'package:greennest/Admin/admin_dashboard.dart';
import 'dart:convert';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_button.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field.dart';
import 'package:greennest/Widget/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.showLoader(message: loadingIn);

    try {
      final response = await ApiService.loginUser(
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );

      context.hideLoader();
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);

          // Check if login was successful
          if (data['token'] != null && data['email'] != null) {
            CustomToast.success(
              title: 'Welcome Back',
              message: 'Login successful',
            );

            print('Token: ${data["token"]}');
            print('User Email: ${data["email"]}');

            // Small delay to let toast display, then navigate
            await Future.delayed(const Duration(milliseconds: 500));

            if (!mounted) return;

            // Check if user is admin
            bool isAdmin = emailCtrl.text.toLowerCase() == 'admin@example.com';

            if (isAdmin) {
              // Route to admin dashboard
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AdminDashboard(
                      email: data["email"],
                      token: data["token"],
                    ),
                  ),
                );
              }
            } else {
              // Route to main navigation screen for regular users
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainNavigationScreen(
                      email: data["email"],
                      token: data["token"],
                    ),
                  ),
                );
              }
            }
          } else {
            CustomToast.error(
              title: 'Login Failed',
              message: 'Invalid server response',
            );
          }
        } else {
          CustomToast.error(
            title: 'Login Failed',
            message: 'No response from server',
          );
        }
      } else {
        String errorMessage = 'Login failed (Status: ${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }

        print('Login Error: $errorMessage');
        CustomToast.error(
          title: 'Login Failed',
          message: 'Invalid credentials',
        );
      }
    } catch (e) {
      context.hideLoader();
      print('Login Exception: $e');

      CustomToast.error(
        title: 'Connection Error',
        message: 'Check your internet connection',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                SizedBox(height: 32),
                // Headline
                CustomText(
                  text: loginHeadline,
                  textColor: Colors.black,
                  textSize: GSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                // Subheadline
                CustomText(
                  text: loginSubHeadline,
                  textColor: Colors.grey[600] ?? Colors.grey,
                  textSize: GSizes.fontSizeMd,
                  fontWeight: FontWeight.normal,
                ),
                SizedBox(height: 32),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 12),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(ForgotPasswordScreen()),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 30),
                          ),
                          child: Text(
                            forgotPassword,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 28),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: login,
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
                              Icon(Icons.login_rounded,
                                  size: 22, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                loginText,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.push(RegisterScreen()),
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
                                Icons.person_add_rounded,
                                size: 22,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 12),
                              Text(
                                dontHaveAnAccount,
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

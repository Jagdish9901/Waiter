// today codept

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:waiter_app/dashboardScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(_usernameFocus);
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void showMessageDialog(
      String title, String message, VoidCallback onDialogClose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), onDialogClose);
            },
            child: Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    String username = _username.text.trim();
    String password = _password.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessageDialog(
          "Missing Information", "Please enter your username and password.",
          () {
        FocusScope.of(context).requestFocus(_usernameFocus);
      });
      return;
    }

    String apiUrl =
        "https://hotelserver.billhost.co.in/checkWaiter/$username/$password";

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', username);
          await prefs.setString('userData', jsonEncode(responseData));

          // Use null-safe access and provide default values to prevent crashes
          await prefs.setString(
              'wname', responseData[0]['wname'] ?? "Unknown Waiter");
          await prefs.setInt('wcode', responseData[0]['shopid'] ?? 0);
          await prefs.setInt('wid', responseData[0]['id'] ?? 0);

          // print("Stored Waiter ID: ${prefs.getInt('wid')}");

          // Navigate to DashBoardScreen after login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashBoardScreen(
                responseData: responseData,
                itemCounts: {},
                menuItems: [],
                selectedOption: null,
              ),
            ),
          );
        } else {
          showMessageDialog("Login Failed", "Invalid username or password.",
              () {
            FocusScope.of(context).requestFocus(_usernameFocus);
          });
        }
      } else {
        showMessageDialog("Login Failed", "Invalid username or password.", () {
          FocusScope.of(context).requestFocus(_usernameFocus);
        });
      }
    } catch (e) {
      showMessageDialog("Error", "An error occurred: $e", () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFB300),
              Color(0xFFFFC107),
              Color(0xFFFFE082),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to the Waiter App",
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 5.h),
                Text("Username",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                TextField(
                  controller: _username,
                  focusNode: _usernameFocus,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black), // Default border color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5), // Black border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2), // Black border when focused
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black,
                      )),
                ),
                SizedBox(height: 3.h),
                Text("Password",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                TextField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  obscureText: passwordVisible,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black), // Default black border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5), // Black border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2), // Black border when focused
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      // suffixIcon: IconButton(
                      //   color: Colors.black,
                      //   icon: Icon(passwordVisible
                      //       ? Icons.visibility
                      //       : Icons.visibility_off),
                      //   onPressed: () {
                      //     setState(() {
                      //       passwordVisible = !passwordVisible;
                      //     });
                      //   },
                      // ),
                      suffixIcon: IconButton(
                        color: Colors.black,
                        icon: Icon(passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      )),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Color(0xFFFFE082),
                      backgroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Log in",
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
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

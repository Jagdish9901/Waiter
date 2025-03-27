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

  bool passwordVisible = false;

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
        if (responseData.isNotEmpty) {
          // print(responseData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', username);
          await prefs.setString('userData', jsonEncode(responseData));

          // Store waiter name from response
          await prefs.setString('wname', responseData[0]['wname']);
          await prefs.setInt('wcode', responseData[0]['shopid']);

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
              // Color(0xFF6A11CB),
              //  Color(0xFF2575FC),
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
                  obscureText: !passwordVisible,
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
                    suffixIcon: IconButton(
                      color: Colors.black,
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
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


// orange color ui

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:waiter_app/dashboardScreen.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _username = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   final FocusNode _usernameFocus = FocusNode();
//   final FocusNode _passwordFocus = FocusNode();

//   bool passwordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 500), () {
//       FocusScope.of(context).requestFocus(_usernameFocus);
//     });
//   }

//   @override
//   void dispose() {
//     _username.dispose();
//     _password.dispose();
//     _usernameFocus.dispose();
//     _passwordFocus.dispose();
//     super.dispose();
//   }

//   void showMessageDialog(
//       String title, String message, VoidCallback onDialogClose) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Future.delayed(const Duration(milliseconds: 300), onDialogClose);
//             },
//             child: const Text("OK", style: TextStyle(color: Colors.blue)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> login() async {
//     String username = _username.text.trim();
//     String password = _password.text.trim();

//     if (username.isEmpty || password.isEmpty) {
//       showMessageDialog(
//           "Missing Information", "Please enter your username and password.",
//           () {
//         FocusScope.of(context).requestFocus(_usernameFocus);
//       });
//       return;
//     }

//     String apiUrl =
//         "https://hotelserver.billhost.co.in/checkWaiter/$username/$password";

//     try {
//       var response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);
//         if (responseData.isNotEmpty) {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('isLoggedIn', true);
//           await prefs.setString('username', username);
//           await prefs.setString('userData', jsonEncode(responseData));
//           await prefs.setString('wname', responseData[0]['wname']);
//           await prefs.setInt('wcode', responseData[0]['shopid']);

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DashBoardScreen(
//                 responseData: responseData,
//                 itemCounts: {},
//                 menuItems: [],
//                 selectedOption: null,
//               ),
//             ),
//           );
//         } else {
//           showMessageDialog("Login Failed", "Invalid username or password.",
//               () {
//             FocusScope.of(context).requestFocus(_usernameFocus);
//           });
//         }
//       } else {
//         showMessageDialog("Login Failed", "Invalid username or password.", () {
//           FocusScope.of(context).requestFocus(_usernameFocus);
//         });
//       }
//     } catch (e) {
//       showMessageDialog("Error", "An error occurred: $e", () {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: 100.w,
//         height: 100.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.orange.shade600,
//               Colors.orange.shade400,
//               Colors.orange.shade200,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8.w),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Text(
//                       "Waiter App",
//                       style: TextStyle(
//                         fontSize: 27.sp,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.white,
//                         shadows: [
//                           Shadow(
//                             blurRadius: 5.0,
//                             color: Colors.black.withOpacity(0.3),
//                             offset: const Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   Text("Username",
//                       style: TextStyle(fontSize: 16.sp, color: Colors.white)),
//                   TextField(
//                     controller: _username,
//                     focusNode: _usernameFocus,
//                     style: const TextStyle(color: Colors.white),
//                     cursorColor: Colors.white,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white.withOpacity(0.2),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 3.h),
//                   Text("Password",
//                       style: TextStyle(fontSize: 16.sp, color: Colors.white)),
//                   TextField(
//                     controller: _password,
//                     focusNode: _passwordFocus,
//                     obscureText: !passwordVisible,
//                     style: const TextStyle(color: Colors.white),
//                     cursorColor: Colors.white,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white.withOpacity(0.2),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: const BorderSide(color: Colors.white),
//                       ),
//                       suffixIcon: IconButton(
//                         color: Colors.white,
//                         icon: Icon(passwordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off),
//                         onPressed: () {
//                           setState(() {
//                             passwordVisible = !passwordVisible;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 7.h,
//                     child: ElevatedButton(
//                       onPressed: login,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                       ),
//                       child: Text(
//                         "Log in",
//                         style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange.shade800),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

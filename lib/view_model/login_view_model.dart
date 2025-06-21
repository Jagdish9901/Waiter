// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/api_services/login_service.dart';
// import '../dashboardScreen.dart';

// class LoginViewModel extends ChangeNotifier {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final FocusNode usernameFocus = FocusNode();
//   final FocusNode passwordFocus = FocusNode();

//   bool isPasswordVisible = true;
//   final LoginService _loginService = LoginService();

//   Future<void> login(BuildContext context) async {
//     final username = usernameController.text.trim();
//     final password = passwordController.text.trim();

//     if (username.isEmpty || password.isEmpty) {
//       _showDialog(context, "Missing Information", "Please enter both fields");
//       return;
//     }

//     try {
//       final data = await _loginService.loginUser(username, password);
//       if (data.isNotEmpty) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//         await prefs.setString('username', username);
//         await prefs.setString('userData', data.toString());
//         await prefs.setString('wname', data[0]['wname'] ?? "Unknown");
//         await prefs.setInt('wcode', data[0]['shopid'] ?? 0);
//         await prefs.setInt('wid', data[0]['id'] ?? 0);

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => DashBoardScreen(
//               responseData: data,
//               itemCounts: {},
//               menuItems: [],
//               selectedOption: null,
//             ),
//           ),
//         );
//       } else {
//         _showDialog(context, "Login Failed", "Invalid username or password");
//       }
//     } catch (e) {
//       _showDialog(context, "Error", e.toString());
//     }
//   }

//   void togglePasswordVisibility() {
//     isPasswordVisible = !isPasswordVisible;
//     notifyListeners();
//   }

//   void _showDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context), child: const Text("OK"))
//         ],
//       ),
//     );
//   }

//   void disposeResources() {
//     usernameController.dispose();
//     passwordController.dispose();
//     usernameFocus.dispose();
//     passwordFocus.dispose();
//   }
// }

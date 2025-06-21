// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/api_services/notification_service.dart';
// import 'dart:convert';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:waiter_app/dashboardscreen.dart';
// import 'package:waiter_app/firebase_options.dart';
// import 'package:waiter_app/login.dart';
// import 'package:waiter_app/providers/cartprovider.dart';
// import 'package:waiter_app/providers/notification_provider.dart';

// void main() async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.initialize();

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//   List<dynamic> responseData = [];
//   if (isLoggedIn) {
//     responseData = jsonDecode(prefs.getString('userData') ?? '[]');
//   }

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => CartProvider()),
//         ChangeNotifierProvider(
//             create: (context) => NotificationProvider()), //  Add this line
//       ],
//       child: MyApp(isLoggedIn: isLoggedIn, responseData: responseData),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;
//   final List<dynamic> responseData;

//   const MyApp({
//     super.key,
//     required this.isLoggedIn,
//     required this.responseData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveSizer(
//       builder: (context, orientation, screenType) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           home: isLoggedIn
//               ? DashBoardScreen(
//                   responseData: responseData,
//                   itemCounts: Provider.of<CartProvider>(context).itemCounts,
//                   menuItems: Provider.of<CartProvider>(context).cartItems,
//                   selectedOption:
//                       Provider.of<CartProvider>(context).selectedOption,
//                 )
//               : LoginScreen(),
//         );
//       },
//     );
//   }
// }

//firebase related code

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/api_services/notification_service.dart';
import 'dart:convert';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:waiter_app/dashboardscreen.dart';
import 'package:waiter_app/firebase_options.dart';
import 'package:waiter_app/login.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/providers/notification_provider.dart';
// import 'package:waiter_app/view/login_screen.dart';

// Global key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service (will generate FCM token)
  await NotificationService.initialize();

  // Check login status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  List<dynamic> responseData = [];

  if (isLoggedIn) {
    responseData = jsonDecode(prefs.getString('userData') ?? '[]');

    // Get and print FCM token after login
    String? token = await NotificationService.getFCMToken();
    debugPrint('User FCM Token: $token');
    // Send this token to your backend server here
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, responseData: responseData),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final List<dynamic> responseData;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.responseData,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // For notification navigation
          home: isLoggedIn
              ? DashBoardScreen(
                  responseData: responseData,
                  itemCounts: Provider.of<CartProvider>(context).itemCounts,
                  menuItems: Provider.of<CartProvider>(context).cartItems,
                  selectedOption:
                      Provider.of<CartProvider>(context).selectedOption,
                )
              : LoginScreen(),
        );
      },
    );
  }
}

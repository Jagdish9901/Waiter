import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/api_services/notification_service.dart';
import 'package:waiter_app/cartprovider.dart';
import 'dart:convert';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:waiter_app/dashboardscreen.dart';
import 'package:waiter_app/login.dart';
import 'package:waiter_app/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  List<dynamic> responseData = [];
  if (isLoggedIn) {
    responseData = jsonDecode(prefs.getString('userData') ?? '[]');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
            create: (context) => NotificationProvider()), //  Add this line
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

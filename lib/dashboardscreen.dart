// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/cartprovider.dart';
// import 'package:waiter_app/cartscreen.dart';
// import 'package:waiter_app/homeScreen.dart';
// import 'package:waiter_app/utils/apphelper.dart';
// import 'package:waiter_app/utils/appstring.dart';

// class DashBoardScreen extends StatefulWidget {
//   final List<dynamic> responseData;
//   final Map<int, int> itemCounts;
//   final List<Map<String, dynamic>> menuItems;
//   final String? selectedOption;

//   const DashBoardScreen({
//     Key? key,
//     required this.responseData,
//     required this.itemCounts,
//     required this.menuItems,
//     required this.selectedOption,
//   }) : super(key: key);

//   @override
//   _DashBoardScreenState createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   int _currentIndex = 0;
//   late List<Widget> _screens;
//   FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> devicesList = [];

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(responseData: widget.responseData),
//       Container(), // Empty container for Category to make it unclickable
//       CartScreen(
//         responseData: widget.responseData,
//         itemCounts: widget.itemCounts,
//         menuItems: widget.menuItems,
//         selectedOption: widget.selectedOption,
//       ),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CartProvider>(context, listen: false)
//           .setSelectedOption(widget.selectedOption ?? "None");
//       _checkPrinterPreference();
//     });
//   }

//   void _checkPrinterPreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? printerType = prefs.getString('printerType');

//     if (printerType == null) {
//       _showPrinterSelectionDialog();
//     } else {
//       Apphelper.printerType = printerType!;
//       if (Apphelper.printerType == Appstring.bluetoothPrinter) {
//         if (Apphelper.connectedDevice == null) {
//           scanForDevices();
//         }
//       }
//     }
//   }

//   Future<void> scanForDevices() async {
//     setState(() {
//       devicesList.clear();
//     });

//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//     await FlutterBluePlus.scanResults.listen((results) {
//       for (var result in results) {
//         if (!devicesList.contains(result.device)) {
//           setState(() {
//             devicesList.add(result.device);
//           });
//         }
//       }
//     });
//     if (devicesList.isNotEmpty) {
//       print("object devicesList ${devicesList.length}");
//       _showselectprint();
//     }
//   }

//   void _showPrinterSelectionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Please select your printer"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: Text("USB Printer"),
//                 leading: Icon(Icons.usb),
//                 onTap: () => _savePrinterPreference(Appstring.uSBPrinter),
//               ),
//               ListTile(
//                 title: Text("Bluetooth Printer"),
//                 leading: Icon(Icons.bluetooth),
//                 onTap: () => _savePrinterPreference(Appstring.bluetoothPrinter),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showselectprint() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Please select your printer"),
//           content: ListView.builder(
//             itemCount: devicesList.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(devicesList[index].name.isNotEmpty
//                     ? devicesList[index].name
//                     : "Unknown"),
//                 subtitle: Text(devicesList[index].id.toString()),
//                 onTap: () => connectToPrinter(devicesList[index]),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> connectToPrinter(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         Apphelper.connectedDevice = device;
//       });
//       Navigator.of(context).pop();
//       print("Connected to ${device.name}");
//     } catch (e) {
//       Navigator.of(context).pop();
//       print("Error connecting to device: $e");
//     }
//   }

//   /// Disconnect printer
//   Future<void> disconnectPrinter() async {
//     if (Apphelper.connectedDevice != null) {
//       await Apphelper.connectedDevice!.disconnect();
//       setState(() {
//         Apphelper.connectedDevice = null;
//       });
//       print("Printer disconnected.");
//     }
//   }

//   void _savePrinterPreference(String printerType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('printerType', printerType);
//     Apphelper.printerType = printerType;
//     Navigator.of(context).pop(); // Close dialog
//     if (printerType == Appstring.bluetoothPrinter) {
//       scanForDevices();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           return ClipRRect(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10), topRight: Radius.circular(20.0)),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 if (index != 1) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 }
//               },
//               backgroundColor: Colors.white,
//               selectedItemColor: Color(0xFFFFB300),
//               unselectedItemColor: Colors.black,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.category,
//                       color: Colors.grey), // Disabled category icon
//                   label: 'Category',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Icon(Icons.shopping_cart),
//                       if (cartProvider.totalItemsCount > 0)
//                         Positioned(
//                           right: -8,
//                           top: -8,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: BoxConstraints(
//                               minWidth: 2.w,
//                               minHeight: 2.h,
//                             ),
//                             child: Text(
//                               cartProvider.totalItemsCount.toString(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   label: 'Cart',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

//today

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/api_services/api_service.dart';
// import 'package:waiter_app/cartprovider.dart';
// import 'package:waiter_app/cartscreen.dart';
// import 'package:waiter_app/homeScreen.dart';
// import 'package:waiter_app/providers/notification_provider.dart';
// import 'package:waiter_app/utils/apphelper.dart';
// import 'package:waiter_app/utils/appstring.dart';

// class DashBoardScreen extends StatefulWidget {
//   final List<dynamic> responseData;
//   final Map<int, int> itemCounts;
//   final List<Map<String, dynamic>> menuItems;
//   final String? selectedOption;

//   const DashBoardScreen({
//     Key? key,
//     required this.responseData,
//     required this.itemCounts,
//     required this.menuItems,
//     required this.selectedOption,
//   }) : super(key: key);

//   @override
//   _DashBoardScreenState createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   int _currentIndex = 0;
//   late List<Widget> _screens;
//   FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> devicesList = [];
//   ApiService _apiService = ApiService(); // Instance of ApiService

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(responseData: widget.responseData),
//       Container(), // Empty container for Category to make it unclickable
//       CartScreen(
//         responseData: widget.responseData,
//         itemCounts: widget.itemCounts,
//         menuItems: widget.menuItems,
//         selectedOption: widget.selectedOption,
//       ),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       Provider.of<CartProvider>(context, listen: false)
//           .setSelectedOption(widget.selectedOption ?? "None");

//       // Initialize notifications
//       await Provider.of<NotificationProvider>(context, listen: false)
//           .initializeNotifications();

//       _checkPrinterPreference();

//       // Start the notification polling
//       Timer.periodic(Duration(seconds: 6), (timer) {
//         _startNotificationPolling();
//       });
//     });
//   }

//   // void initState() {
//   //   super.initState();
//   //   _screens = [
//   //     HomeScreen(responseData: widget.responseData),
//   //     Container(), // Empty container for Category to make it unclickable
//   //     CartScreen(
//   //       responseData: widget.responseData,
//   //       itemCounts: widget.itemCounts,
//   //       menuItems: widget.menuItems,
//   //       selectedOption: widget.selectedOption,
//   //     ),
//   //   ];

//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     Provider.of<CartProvider>(context, listen: false)
//   //         .setSelectedOption(widget.selectedOption ?? "None");
//   //     _checkPrinterPreference();

//   //     // Start the notification polling

//   //     Timer.periodic(Duration(seconds: 6), (timer) {
//   //       _startNotificationPolling();
//   //     });
//   //     // _startNotificationPolling();
//   //   });
//   // }

//   void _checkPrinterPreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? printerType = prefs.getString('printerType');

//     if (printerType == null) {
//       _showPrinterSelectionDialog();
//     } else {
//       Apphelper.printerType = printerType!;
//       if (Apphelper.printerType == Appstring.bluetoothPrinter) {
//         if (Apphelper.connectedDevice == null) {
//           scanForDevices();
//         }
//       }
//     }
//   }

//   Future<void> scanForDevices() async {
//     setState(() {
//       devicesList.clear();
//     });

//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//     await FlutterBluePlus.scanResults.listen((results) {
//       for (var result in results) {
//         if (!devicesList.contains(result.device)) {
//           setState(() {
//             devicesList.add(result.device);
//           });
//         }
//       }
//     });
//     if (devicesList.isNotEmpty) {
//       print("object devicesList ${devicesList.length}");
//       _showselectprint();
//     }
//   }

//   void _showPrinterSelectionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Please select your printer"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: Text("USB Printer"),
//                 leading: Icon(Icons.usb),
//                 onTap: () => _savePrinterPreference(Appstring.uSBPrinter),
//               ),
//               ListTile(
//                 title: Text("Bluetooth Printer"),
//                 leading: Icon(Icons.bluetooth),
//                 onTap: () => _savePrinterPreference(Appstring.bluetoothPrinter),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showselectprint() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Please select your printer"),
//           content: ListView.builder(
//             itemCount: devicesList.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(devicesList[index].name.isNotEmpty
//                     ? devicesList[index].name
//                     : "Unknown"),
//                 subtitle: Text(devicesList[index].id.toString()),
//                 onTap: () => connectToPrinter(devicesList[index]),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> connectToPrinter(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         Apphelper.connectedDevice = device;
//       });
//       Navigator.of(context).pop();
//       print("Connected to ${device.name}");
//     } catch (e) {
//       Navigator.of(context).pop();
//       print("Error connecting to device: $e");
//     }
//   }

//   /// Disconnect printer
//   Future<void> disconnectPrinter() async {
//     if (Apphelper.connectedDevice != null) {
//       await Apphelper.connectedDevice!.disconnect();
//       setState(() {
//         Apphelper.connectedDevice = null;
//       });
//       print("Printer disconnected.");
//     }
//   }

//   void _savePrinterPreference(String printerType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('printerType', printerType);
//     Apphelper.printerType = printerType;
//     Navigator.of(context).pop(); // Close dialog
//     if (printerType == Appstring.bluetoothPrinter) {
//       scanForDevices();
//     }
//   }

//   // Start the notification polling
//   void _startNotificationPolling() {
//     final prefs = SharedPreferences.getInstance();
//     prefs.then((sharedPrefs) {
//       int shopId = sharedPrefs.getInt('wcode') ?? 0;
//       int wid = sharedPrefs.getInt("wid") ?? 0;
//       // print("object wid $wid");
//       // print(shopId.toString());

//       if (shopId > 0 && wid > 0) {
//         // print("object start");
//         // _apiService.startNotificationPolling(context, shopid, wid);
//         _apiService.startNotificationPolling(context);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           return ClipRRect(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10), topRight: Radius.circular(20.0)),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 if (index != 1) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 }
//               },
//               backgroundColor: Colors.white,
//               selectedItemColor: Color(0xFFFFB300),
//               unselectedItemColor: Colors.black,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.category,
//                       color: Colors.grey), // Disabled category icon
//                   label: 'Category',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Icon(Icons.shopping_cart),
//                       if (cartProvider.totalItemsCount > 0)
//                         Positioned(
//                           right: -8,
//                           top: -8,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: BoxConstraints(
//                               minWidth: 2.w,
//                               minHeight: 2.h,
//                             ),
//                             child: Text(
//                               cartProvider.totalItemsCount.toString(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   label: 'Cart',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ssssssccscc

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/api_services/api_service.dart';
// import 'package:waiter_app/cartscreen.dart';
// import 'package:waiter_app/homeScreen.dart';
// import 'package:waiter_app/providers/cartprovider.dart';
// import 'package:waiter_app/providers/notification_provider.dart';
// import 'package:waiter_app/utils/apphelper.dart';
// import 'package:waiter_app/utils/appstring.dart';

// class DashBoardScreen extends StatefulWidget {
//   final List<dynamic> responseData;
//   final Map<int, int> itemCounts;
//   final List<Map<String, dynamic>> menuItems;
//   final String? selectedOption;

//   const DashBoardScreen({
//     Key? key,
//     required this.responseData,
//     required this.itemCounts,
//     required this.menuItems,
//     required this.selectedOption,
//   }) : super(key: key);

//   @override
//   _DashBoardScreenState createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   int _currentIndex = 0;
//   late List<Widget> _screens;
//   FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> devicesList = [];
//   ApiService _apiService = ApiService();
//   Timer? _pollingTimer;

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(responseData: widget.responseData),
//       Container(), // Disabled Category screen
//       CartScreen(
//         responseData: widget.responseData,
//         itemCounts: widget.itemCounts,
//         menuItems: widget.menuItems,
//         selectedOption: widget.selectedOption,
//       ),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       Provider.of<CartProvider>(context, listen: false)
//           .setSelectedOption(widget.selectedOption ?? "None");

//       await Provider.of<NotificationProvider>(context, listen: false)
//           .initializeNotifications();

//       _checkPrinterPreference();

//       _startNotificationPolling();
//     });
//   }

//   void _startNotificationPolling() {
//     _pollingTimer?.cancel(); // Cancel previous timers if any

//     _pollingTimer = Timer.periodic(Duration(seconds: 6), (timer) async {
//       final prefs = await SharedPreferences.getInstance();
//       int shopId = prefs.getInt('wcode') ?? 0;
//       int wid = prefs.getInt("wid") ?? 0;
//       if (shopId > 0 && wid > 0) {
//         _apiService.startNotificationPolling(context);
//       }
//     });
//   }

//   void _stopNotificationPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = null;
//   }

//   void _checkPrinterPreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? printerType = prefs.getString('printerType');
//     if (printerType == null) {
//       _showPrinterSelectionDialog();
//     } else {
//       Apphelper.printerType = printerType;
//       if (printerType == Appstring.bluetoothPrinter &&
//           Apphelper.connectedDevice == null) {
//         scanForDevices();
//       }
//     }
//   }

//   Future<void> scanForDevices() async {
//     devicesList.clear();
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//     FlutterBluePlus.scanResults.listen((results) {
//       for (var result in results) {
//         if (!devicesList.contains(result.device)) {
//           setState(() {
//             devicesList.add(result.device);
//           });
//         }
//       }
//     });
//     if (devicesList.isNotEmpty) {
//       _showselectprint();
//     }
//   }

//   void _showPrinterSelectionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("Please select your printer"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: Text("USB Printer"),
//               leading: Icon(Icons.usb),
//               onTap: () => _savePrinterPreference(Appstring.uSBPrinter),
//             ),
//             ListTile(
//               title: Text("Bluetooth Printer"),
//               leading: Icon(Icons.bluetooth),
//               onTap: () => _savePrinterPreference(Appstring.bluetoothPrinter),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showselectprint() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("Please select your printer"),
//         content: ListView.builder(
//           itemCount: devicesList.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: Text(devicesList[index].name.isNotEmpty
//                   ? devicesList[index].name
//                   : "Unknown"),
//               subtitle: Text(devicesList[index].id.toString()),
//               onTap: () => connectToPrinter(devicesList[index]),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> connectToPrinter(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         Apphelper.connectedDevice = device;
//       });
//       Navigator.of(context).pop();
//     } catch (e) {
//       Navigator.of(context).pop();
//       print("Error connecting to printer: $e");
//     }
//   }

//   void _savePrinterPreference(String printerType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('printerType', printerType);
//     Apphelper.printerType = printerType;
//     Navigator.of(context).pop();
//     if (printerType == Appstring.bluetoothPrinter) {
//       scanForDevices();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           return ClipRRect(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(20.0),
//             ),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 if (index != 1) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 }
//               },
//               backgroundColor: Colors.white,
//               selectedItemColor: Color(0xFFFFB300),
//               unselectedItemColor: Colors.black,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.category, color: Colors.grey),
//                   label: 'Category',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Icon(Icons.shopping_cart),
//                       if (cartProvider.totalItemsCount > 0)
//                         Positioned(
//                           right: -8,
//                           top: -8,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: BoxConstraints(
//                               minWidth: 2.w,
//                               minHeight: 2.h,
//                             ),
//                             child: Text(
//                               cartProvider.totalItemsCount.toString(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   label: 'Cart',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// new code

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/api_services/api_service.dart';
import 'package:waiter_app/cartscreen.dart';
import 'package:waiter_app/homeScreen.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/providers/notification_provider.dart';
import 'package:waiter_app/utils/apphelper.dart';
import 'package:waiter_app/utils/appstring.dart';

class DashBoardScreen extends StatefulWidget {
  final List<dynamic> responseData;
  final Map<int, int> itemCounts;
  final List<Map<String, dynamic>> menuItems;
  final String? selectedOption;

  const DashBoardScreen({
    Key? key,
    required this.responseData,
    required this.itemCounts,
    required this.menuItems,
    required this.selectedOption,
  }) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devicesList = [];
  ApiService _apiService = ApiService();
  Timer? _pollingTimer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(responseData: widget.responseData),
      Container(), // Disabled Category screen
      CartScreen(
        responseData: widget.responseData,
        itemCounts: widget.itemCounts,
        menuItems: widget.menuItems,
        selectedOption: widget.selectedOption,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CartProvider>(context, listen: false)
          .setSelectedOption(widget.selectedOption ?? "None");

      await Provider.of<NotificationProvider>(context, listen: false)
          .initializeNotifications();

      _checkPrinterPreference();

      _startNotificationPolling();
    });
  }

  @override
  void dispose() {
    _stopScanning();
    _pollingTimer?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _startNotificationPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 6), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      int shopId = prefs.getInt('wcode') ?? 0;
      int wid = prefs.getInt("wid") ?? 0;
      if (shopId > 0 && wid > 0) {
        _apiService.startNotificationPolling(context);
      }
    });
  }

  void _stopNotificationPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _checkPrinterPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? printerType = prefs.getString('printerType');
    if (printerType == null) {
      _showPrinterSelectionDialog();
    } else {
      Apphelper.printerType = printerType;
      if (printerType == Appstring.bluetoothPrinter &&
          Apphelper.connectedDevice == null) {
        await scanForDevices();
      }
    }
  }

  Future<void> scanForDevices() async {
    try {
      // Check if Bluetooth is available
      bool isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        _showErrorDialog("Bluetooth is not available on this device");
        return;
      }

      // Check if Bluetooth is on
      bool isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        _showErrorDialog("Please turn on Bluetooth to scan for devices");
        return;
      }

      setState(() {
        _isScanning = true;
        devicesList.clear();
      });

      // Start scan with timeout
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;

        setState(() {
          for (var result in results) {
            if (!devicesList.any((device) => device.id == result.device.id)) {
              devicesList.add(result.device);
            }
          }
        });
      }, onError: (e) {
        if (!mounted) return;
        _showErrorDialog("Scan error: ${e.toString()}");
      });

      // Show devices after scan completes
      await Future.delayed(Duration(seconds: 5));
      _stopScanning();

      if (devicesList.isNotEmpty) {
        _showDeviceSelectionDialog();
      } else {
        _showErrorDialog("No Bluetooth printers found");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Error scanning for devices: ${e.toString()}");
    }
  }

  void _stopScanning() {
    if (_isScanning) {
      FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showPrinterSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Select Printer Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("USB Printer"),
              leading: Icon(Icons.usb),
              onTap: () => _savePrinterPreference(Appstring.uSBPrinter),
            ),
            ListTile(
              title: Text("Bluetooth Printer"),
              leading: Icon(Icons.bluetooth),
              onTap: () async {
                Navigator.pop(context);
                await _savePrinterPreference(Appstring.bluetoothPrinter);
                await scanForDevices();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Select Bluetooth Printer"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devicesList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  devicesList[index].name.isNotEmpty
                      ? devicesList[index].name
                      : "Unknown Device",
                ),
                subtitle: Text(devicesList[index].id.toString()),
                onTap: () => connectToPrinter(devicesList[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Connecting..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Connecting to ${device.name}"),
            ],
          ),
        ),
      );

      await device.connect(autoConnect: false);
      await Future.delayed(Duration(seconds: 1)); // Small delay for stability

      setState(() {
        Apphelper.connectedDevice = device;
      });

      Navigator.of(context).pop(); // Close connecting dialog
      Navigator.of(context).pop(); // Close device selection dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${device.name}")),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close connecting dialog
      _showErrorDialog("Failed to connect: ${e.toString()}");
    }
  }

  Future<void> _savePrinterPreference(String printerType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerType', printerType);
    Apphelper.printerType = printerType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_isScanning)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  // Text("Scanning for Bluetooth printers..."),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(20.0),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index != 1) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFFFFB300),
              unselectedItemColor: Colors.black,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category, color: Colors.grey),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart),
                      if (cartProvider.totalItemsCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 2.w,
                              minHeight: 2.h,
                            ),
                            child: Text(
                              cartProvider.totalItemsCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

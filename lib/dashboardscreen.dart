// import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:waiter_app/cartprovider.dart';
// import 'package:waiter_app/cartscreen.dart';
// import 'package:waiter_app/homeScreen.dart';

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

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(responseData: widget.responseData),
//       CartScreen(
//           responseData: widget
//               .responseData), // ✅ Now CartScreen gets selectedOption from Provider
//     ];

//     // ✅ Set initial selected option in CartProvider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CartProvider>(context, listen: false)
//           .setSelectedOption(widget.selectedOption ?? "None");
//     });
//   }

//   final List<IconData> _icons = [
//     Icons.home,
//     Icons.shopping_cart,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement category selection or any required action
//         },
//         backgroundColor: Color(0xFFFFB300),
//         child: const Icon(Icons.category, color: Colors.black),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           return AnimatedBottomNavigationBar.builder(
//             itemCount: _icons.length,
//             tabBuilder: (int index, bool isActive) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Icon(
//                         _icons[index],
//                         size: 30,
//                         color: isActive ? Color(0xFFFFB300) : Colors.grey,
//                       ),
//                       if (index == 1 && cartProvider.totalItemsCount > 0)
//                         Positioned(
//                           right: -5,
//                           top: -5,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: const BoxConstraints(
//                               minWidth: 20,
//                               minHeight: 20,
//                             ),
//                             child: Text(
//                               cartProvider.totalItemsCount.toString(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                 ],
//               );
//             },
//             activeIndex: _currentIndex,
//             gapLocation: GapLocation.center,
//             notchSmoothness: NotchSmoothness.softEdge,
//             backgroundColor: Colors.white,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:waiter_app/cartprovider.dart';
// import 'package:waiter_app/cartscreen.dart';
// import 'package:waiter_app/homeScreen.dart';

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

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       HomeScreen(responseData: widget.responseData),
//       Container(), // Placeholder for Category
//       CartScreen(responseData: widget.responseData),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CartProvider>(context, listen: false)
//           .setSelectedOption(widget.selectedOption ?? "None");
//     });
//   }

//   final List<IconData> _icons = [
//     Icons.home,
//     Icons.category,
//     Icons.shopping_cart,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           return BottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             backgroundColor: Colors.white,
//             selectedItemColor: Color(0xFFFFB300),
//             unselectedItemColor: Colors.grey,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.category),
//                 label: 'Category',
//               ),
//               BottomNavigationBarItem(
//                 icon: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Icon(Icons.shopping_cart),
//                     if (cartProvider.totalItemsCount > 0)
//                       Positioned(
//                         right: -5,
//                         top: -5,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           constraints: const BoxConstraints(
//                             minWidth: 20,
//                             minHeight: 20,
//                           ),
//                           child: Text(
//                             cartProvider.totalItemsCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 label: 'Cart',
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// Category non clickable fine code 01/03/25

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/cartprovider.dart';
import 'package:waiter_app/cartscreen.dart';
import 'package:waiter_app/homeScreen.dart';
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

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(responseData: widget.responseData),
      Container(), // Empty container for Category to make it unclickable
      CartScreen(
        responseData: widget.responseData,
        itemCounts: widget.itemCounts,
        menuItems: widget.menuItems,
        selectedOption: widget.selectedOption,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false)
          .setSelectedOption(widget.selectedOption ?? "None");
      _checkPrinterPreference();
    });
  }

  void _checkPrinterPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? printerType = prefs.getString('printerType');

    if (printerType == null) {
      _showPrinterSelectionDialog();
    } else {
      Apphelper.printerType = printerType!;
      if (Apphelper.printerType == Appstring.bluetoothPrinter) {
        if (Apphelper.connectedDevice == null) {
          scanForDevices();
        }
      }
    }
  }

  Future<void> scanForDevices() async {
    setState(() {
      devicesList.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    await FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });
    if (devicesList.isNotEmpty) {
      print("object devicesList ${devicesList.length}");
      _showselectprint();
    }
  }

  void _showPrinterSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Please select your printer"),
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
                onTap: () => _savePrinterPreference(Appstring.bluetoothPrinter),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showselectprint() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Please select your printer"),
          content: ListView.builder(
            itemCount: devicesList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(devicesList[index].name.isNotEmpty
                    ? devicesList[index].name
                    : "Unknown"),
                subtitle: Text(devicesList[index].id.toString()),
                onTap: () => connectToPrinter(devicesList[index]),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        Apphelper.connectedDevice = device;
      });
      Navigator.of(context).pop();
      print("Connected to ${device.name}");
    } catch (e) {
      Navigator.of(context).pop();
      print("Error connecting to device: $e");
    }
  }

  /// Disconnect printer
  Future<void> disconnectPrinter() async {
    if (Apphelper.connectedDevice != null) {
      await Apphelper.connectedDevice!.disconnect();
      setState(() {
        Apphelper.connectedDevice = null;
      });
      print("Printer disconnected.");
    }
  }

  void _savePrinterPreference(String printerType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerType', printerType);
    Apphelper.printerType = printerType;
    Navigator.of(context).pop(); // Close dialog
    if (printerType == Appstring.bluetoothPrinter) {
      scanForDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return BottomNavigationBar(
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
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category,
                    color: Colors.grey), // Disabled category icon
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
          );
        },
      ),
    );
  }
}

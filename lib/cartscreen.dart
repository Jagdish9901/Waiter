import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/billItem.dart';
import 'package:waiter_app/cartprovider.dart';
import 'package:waiter_app/dashboardscreen.dart';
import 'package:waiter_app/utils/apphelper.dart';
import 'package:waiter_app/utils/appstring.dart';

class CartScreen extends StatefulWidget {
  final List<dynamic> responseData;
  final Map<int, int> itemCounts;
  final List<Map<String, dynamic>> menuItems;
  final String? selectedOption;

  const CartScreen({
    Key? key,
    required this.responseData,
    required this.itemCounts,
    required this.menuItems,
    required this.selectedOption,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();

  Future<void> _postCartData(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final selectedItems = cartProvider.cartItems;

    debugPrint("Starting _postCartData...");

    if (selectedItems.isEmpty) {
      debugPrint("Cart is empty. Aborting request.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty!")),
      );
      return;
    }

    // Retrieve logged-in waiter name from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final waiterName = prefs.getString("wname") ?? "Unknown";
    // debugPrint("Logged-in waiter: $waiterName");

    // Determine kottype value based on selected order type
    int kottype = 0;
    if (cartProvider.selectedOption == "Table") {
      kottype = cartProvider.selectedTableId != null ? 0 : 1;
    } else if (cartProvider.selectedOption == "Delivery") {
      kottype = 2;
    } else if (cartProvider.selectedOption == "Takeaway") {
      kottype = 3;
    }
    debugPrint("Order type: ${cartProvider.selectedOption}, kottype: $kottype");

    // Construct API request body
    List<Map<String, dynamic>> orderItems = selectedItems.map((item) {
      int quantity = cartProvider.itemCounts[item['id']] ?? 1;

      final itemData = {
        "rawcode": item['id'],
        "itname": item['itname'],
        "barcode": item['barcode'] ?? "0000",
        "discperc": 0,
        "qty": quantity,
        // "rate": item['restrate'] ?? 0,
        "rate": (Apphelper()
            .totalgst(item['restrate'], item['cess'], item['gst'],
                Apphelper.gsttype!, quantity)
            .toStringAsFixed(2)),
        "gst": item['gst'],
        "cess": item['cess'],
        "itcomment": "",
        "isdiscountable": 0,
        "id": "",
        "shopid": widget.responseData[0]['shopid'],
        "kdsstatus": 1,
        "timeotp": DateTime.now().millisecondsSinceEpoch.toString(),
        "kottime":
            "${TimeOfDay.now().hour}:${TimeOfDay.now().minute} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}",
        "tablecode": cartProvider.selectedOption == "Table"
            ? cartProvider.selectedTableId
            : 0,
        "tablename": cartProvider.selectedOption == "Table"
            ? cartProvider.selectedTableName ?? "Unknown"
            : "None",
        "ordertype": cartProvider.selectedOption ?? "None",
        "wcode": widget.responseData[0]['id'],
        "wname": widget.responseData[0]['wname'],
        "nop": 1,
        "kottype": kottype,
        "bltype": 0,
        "discamt": 0,
        "bldiscperc": 0,
        "bldiscamt": 0,
        "taxableamt": (item['restrate'] ?? 0) * quantity,
        "gstamt": (item['restrate'] ?? 0) * quantity * 0.05,
        "cessamt": 0,
        "servicechperc": 12,
        "servicechamt": (item['restrate'] ?? 0) * quantity * 0.12,
        "ittotal": ((item['restrate'] ?? 0) * quantity * 1.17).round(),
        "totqty": quantity,
        "totaltaxableamt":
            ((item['restrate'] ?? 0) * quantity).toStringAsFixed(2),
        "totgst":
            ((item['restrate'] ?? 0) * quantity * 0.05).toStringAsFixed(2),
        "totcess": "0.00",
        "totdiscamt": "0.00",
        "totbldiscamt": "0.00",
        "totalservicechamt":
            ((item['restrate'] ?? 0) * quantity * 0.12).toStringAsFixed(2),
        "roundoff": "0.00",
        "totblamt": ((item['restrate'] ?? 0) * quantity * 1.17).round(),
        "totordamt": ((item['restrate'] ?? 0) * quantity * 1.05).round(),
      };

      // debugPrint("Item added to order: ${jsonEncode(itemData)}");
      return itemData;
    }).toList();

    final url = Uri.parse("https://hotelserver.billhost.co.in/DineinKOT");
    // debugPrint("API URL: $url");

    try {
      debugPrint("Sending order data to server...");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderItems),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("--------Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Order placed successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );
        cartProvider.clearCart();
        //  Navigate to DashboardScreen after successful order
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashBoardScreen(
              responseData: widget.responseData, // Pass the required data
              itemCounts:
                  widget.itemCounts, // Ensure you pass the correct state data
              menuItems:
                  widget.menuItems, // Ensure you pass the correct menu items
              selectedOption: widget.selectedOption, // Pass selected option
            ),
          ),
        );
      } else {
        debugPrint("Failed to place order: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    debugPrint("Finished _postCartData.");
  }

  Future<void> _postCartDataprintandorder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final selectedItems = cartProvider.cartItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty!")),
      );
      return;
    }

    // Retrieve logged-in waiter name from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final waiterName = prefs.getString("wname") ?? "Unknown";
    final selectedPrinterType = prefs.getString("printer_type") ??
        "USB Printer"; // Retrieve stored printer type

    //  Cache the values immediately
    final selectedOption = cartProvider.selectedOption ?? "None";
    final selectedTableId = cartProvider.selectedTableId ?? 0;
    final selectedTableName = cartProvider.selectedTableName ?? "None";

    // Determine kottype value based on selected order type
    int kottype = 0; // Default for 'Table'
    if (selectedOption == "Table") {
      kottype = selectedTableId != 0 ? 0 : 1;
    } else if (selectedOption == "Delivery") {
      kottype = 2;
    } else if (selectedOption == "Takeaway") {
      kottype = 3;
    }

    // Debug prints to verify values
    print("---1--: $selectedOption");
    print("--2----: $selectedTableId");
    print("-----3-- $selectedTableName");

    // Construct API request body
    List<Map<String, dynamic>> orderItems = selectedItems.map((item) {
      int quantity = cartProvider.itemCounts[item['id']] ?? 1;
      double rate = item['restrate'] ?? 0;
      double gstAmount = rate * quantity * 0.05;
      double serviceCharge = rate * quantity * 0.12;
      double totalAmount = rate * quantity * 1.17;

      return {
        "rawcode": item['id'],
        "itname": item['itname'],
        "barcode": item['barcode'] ?? "0000",
        "discperc": 0,
        "qty": quantity,
        // "rate": item['restrate'] ?? 0,
        "rate": (Apphelper()
            .totalgst(item['restrate'], item['cess'], item['gst'],
                Apphelper.gsttype!, quantity)
            .toStringAsFixed(2)),
        "gst": item['gst'],
        "cess": item['cess'],
        "itcomment": "",
        "isdiscountable": 0,
        "id": "",
        "shopid": widget.responseData[0]['shopid'],
        "kdsstatus": 1,
        "timeotp": DateTime.now().millisecondsSinceEpoch.toString(),
        "kottime":
            "${TimeOfDay.now().hour}:${TimeOfDay.now().minute} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}",
        "tablecode": cartProvider.selectedOption == "Table"
            ? cartProvider.selectedTableId
            : 0,
        "tablename": cartProvider.selectedOption == "Table"
            ? cartProvider.selectedTableName ?? "Unknown"
            : "None",
        "ordertype": cartProvider.selectedOption ?? "None",
        "wcode": widget.responseData[0]['id'],
        "wname": widget.responseData[0]['wname'],
        "nop": 1,
        "kottype": kottype,
        "bltype": 0,
        "discamt": 0,
        "bldiscperc": 0,
        "bldiscamt": 0,
        "taxableamt": (item['restrate'] ?? 0) * quantity,
        "gstamt": (item['restrate'] ?? 0) * quantity * 0.05,
        "cessamt": 0,
        "servicechperc": 12,
        "servicechamt": (item['restrate'] ?? 0) * quantity * 0.12,
        "ittotal": ((item['restrate'] ?? 0) * quantity * 1.17).round(),
        "totqty": quantity,
        "totaltaxableamt":
            ((item['restrate'] ?? 0) * quantity).toStringAsFixed(2),
        "totgst":
            ((item['restrate'] ?? 0) * quantity * 0.05).toStringAsFixed(2),
        "totcess": "0.00",
        "totdiscamt": "0.00",
        "totbldiscamt": "0.00",
        "totalservicechamt":
            ((item['restrate'] ?? 0) * quantity * 0.12).toStringAsFixed(2),
        "roundoff": "0.00",
        "totblamt": ((item['restrate'] ?? 0) * quantity * 1.17).round(),
        "totordamt": ((item['restrate'] ?? 0) * quantity * 1.05).round(),
      };
    }).toList();

    final url = Uri.parse("https://hotelserver.billhost.co.in/DineinKOT");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderItems),
      );

      debugPrint("--------Response printer: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );
        cartProvider.clearCart();

        print("---1--: $response}");

        List<BillItem> orderItemsfinal = [];
        for (int i = 0; i < orderItems.length; i++) {
          orderItemsfinal.add(
            BillItem(
                serialNo: i + 1,
                name: orderItems[i]['itname'] ?? "Unknown",
                quantity: orderItems[i]['qty'] ?? "Unknown"),
          );
        }
        print("selectedOption $selectedTableName");
        // Future.delayed(Duration.se,);
        if (Apphelper.printerType == Appstring.bluetoothPrinter) {
          if (Apphelper.connectedDevice != null) {
            await printFormattedBill(
                Apphelper.connectedDevice!,
                "Dine-in",
                "Crossrug",
                "Main",
                response.body.toString(),
                // kottype.toString(),
                selectedTableName,
                "${TimeOfDay.now().hour}:${TimeOfDay.now().minute} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}",
                // "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                "${DateTime.now().day.toString().padLeft(2, '0')}/"
                    "${DateTime.now().month.toString().padLeft(2, '0')}/"
                    "${(DateTime.now().year % 100).toString().padLeft(2, '0')}",
                waiterName,
                "NOP",
                orderItemsfinal);
          }
        }
        //  Navigate to DashboardScreen after successful order and print
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashBoardScreen(
              responseData: widget.responseData, // Pass the required data
              itemCounts:
                  widget.itemCounts, // Ensure you pass the correct state data
              menuItems:
                  widget.menuItems, // Ensure you pass the correct menu items
              selectedOption: widget.selectedOption, // Pass selected option
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

// 3 inch paper

  Future<void> printFormattedBill(
      BluetoothDevice printer,
      String orderType,
      String restaurantName,
      String kitchen,
      String kotNo,
      String tableNo,
      String dateTime,
      String date,
      String waiterName,
      String numOfPersons,
      List<BillItem> items) async {
    try {
      await printer.connect();
      List<BluetoothService> services = await printer.discoverServices();

      // ESC/POS Commands for formatting
      List<int> escPosCommands = [];

      // Order Type (e.g., "Dine-in")
      escPosCommands.addAll([0x1B, 0x61, 0x01]); // Center alignment
      escPosCommands.addAll([0x1B, 0x45, 0x01]); // Bold ON
      escPosCommands.addAll(utf8.encode("$orderType\n"));
      escPosCommands.addAll([0x1B, 0x45, 0x00]); // Bold OFF
      escPosCommands.addAll([0x1B, 0x61, 0x00]); // Left alignment

      // Bold & Centered Restaurant Name
      escPosCommands.addAll([0x1B, 0x61, 0x01]); // Center alignment
      escPosCommands.addAll([0x1B, 0x45, 0x01]); // Bold ON
      escPosCommands.addAll(utf8.encode("${restaurantName.toUpperCase()}\n"));
      escPosCommands.addAll([0x1B, 0x45, 0x00]); // Bold OFF
      escPosCommands.addAll([0x1B, 0x61, 0x00]); // Left alignment

      // Header Information
      escPosCommands.addAll(
          utf8.encode("""------------------------------------------------
Kitchen : $kitchen
------------------------------------------------
Kot No  : $kotNo                    Table : $tableNo
Date    : $date              Time : $dateTime
Waiter  : $waiterName                   NOP   : 0
------------------------------------------------
SN  Item Name                               QTY
------------------------------------------------
"""));

      // Formatting item list dynamically
      double totalQty = 0;
      for (var item in items) {
        totalQty += item.quantity;
        String formattedLine =
            "${item.serialNo.toString().padRight(3)} ${item.name.padRight(40)}${item.quantity.toStringAsFixed(2).padLeft(4)}\n";
        escPosCommands.addAll(utf8.encode(formattedLine));
      }

      // Footer
      escPosCommands.addAll(
          utf8.encode("""------------------------------------------------
                                  Total : ${totalQty.toStringAsFixed(2)}
------------------------------------------------
\n\n\n
"""));

      // **Cut Paper Command**
      escPosCommands.addAll([0x1D, 0x56, 0x00]); // Full cut

      // Convert to Uint8List for Bluetooth printing
      Uint8List printData = Uint8List.fromList(escPosCommands);

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            int chunkSize = 237; // Bluetooth buffer limit

            for (int i = 0; i < printData.length; i += chunkSize) {
              int end = (i + chunkSize < printData.length)
                  ? i + chunkSize
                  : printData.length;
              await characteristic.write(printData.sublist(i, end),
                  withoutResponse: true);
              await Future.delayed(
                  Duration(milliseconds: 50)); // Prevents buffer overflow
            }

            print("Formatted Bill printed successfully.");
            return;
          }
        }
      }
    } catch (e) {
      print("Bluetooth printing error: $e");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selectedItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: Color(0xFFFFB300),
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFB300),
                const Color(0xFFFFC107),
                const Color(0xFFFFE082),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 5.0,
              left: 10.0,
              right: 10.0,
              bottom: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Selected Order Type
                Text(
                  "Order type : ${cartProvider.selectedOption ?? "None"}",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                if (cartProvider.selectedOption == "Table") // Show Table Name
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      "Table No. : ${cartProvider.selectedTableName ?? "None"}",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 1.h),

                if (Apphelper.printerType == Appstring.bluetoothPrinter)
                  if (Apphelper.connectedDevice != null)
                    Text(Apphelper.connectedDevice!.platformName.toString()),

                // Display Cart Items
                Expanded(
                  child: selectedItems.isEmpty
                      ? const Center(
                          child: Text(
                            "No items in cart",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: selectedItems.length,
                          itemBuilder: (context, index) {
                            final item = selectedItems[index];
                            final quantity =
                                cartProvider.itemCounts[item['id']] ?? 0;

                            return Card(
                              elevation: 3,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5, // Adjust width dynamically
                                          child: Text(
                                            item['itname'].toString(),
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),

                                        // Text(
                                        //   item['itname'].toString(),
                                        //   style: TextStyle(
                                        //       fontSize: 12.4.sp,
                                        //       fontWeight: FontWeight.w700),
                                        // ),
                                        // Text(
                                        //   "₹${item['restrate'].toStringAsFixed(2)}",
                                        //   style: TextStyle(
                                        //       fontSize: 14.sp,
                                        //       color: Colors.black),
                                        // ),
                                        Text(
                                          "Price: ₹${(Apphelper().totalgst(item['restrate'], item['cess'], item['gst'], Apphelper.gsttype!, quantity).toStringAsFixed(2))}",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              cartProvider.removeFromCart(item),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(30, 30),
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Icon(Icons.remove,
                                              color: Colors.white, size: 16.sp),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          child: Text(
                                            quantity.toString(),
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              cartProvider.addToCart(item),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(30, 30),
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Icon(Icons.add,
                                              color: Colors.white, size: 16.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              if (cartProvider.selectedOption == null ||
                                  cartProvider.selectedOption == "None") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select order type"),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                                return;
                              }
                              _postCartData(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text("Proceed to Order"),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),

                      // Print and Order Button
                      Expanded(
                        child: SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              if (cartProvider.selectedOption == null ||
                                  cartProvider.selectedOption == "None") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select order type"),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                                return;
                              }
                              _postCartDataprintandorder(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text("Order and Print"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

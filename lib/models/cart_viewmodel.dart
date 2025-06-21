import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/billItem.dart';
import 'package:waiter_app/dashboardscreen.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/utils/apphelper.dart';
import 'package:waiter_app/utils/appstring.dart';

class CartViewModel {
  final BuildContext context;
  final List<dynamic> responseData;
  final Map<int, int> itemCounts;
  final List<Map<String, dynamic>> menuItems;
  final String? selectedOption;

  CartViewModel({
    required this.context,
    required this.responseData,
    required this.itemCounts,
    required this.menuItems,
    required this.selectedOption,
  });

  Future<void> postCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final selectedItems = cartProvider.cartItems;

    // debugPrint("Starting postCartData...");

    if (selectedItems.isEmpty) {
      // debugPrint("Cart is empty. Aborting request.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart is empty , select items to order...."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final waiterName = prefs.getString("wname") ?? "Unknown";
    int kottype = _determineKotType(cartProvider);

    List<Map<String, dynamic>> orderItems = selectedItems.map((item) {
      return _buildOrderItem(item, cartProvider);
    }).toList();

    final url = Uri.parse("https://hotelserver.billhost.co.in/DineinKOT");

    try {
      debugPrint("Sending order data to server...");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderItems),
      );

      _handleOrderResponse(response, cartProvider);
    } catch (e) {
      // debugPrint("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> postCartDataPrintAndOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final selectedItems = cartProvider.cartItems;

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart is empty , select items to order...."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final waiterName = prefs.getString("wname") ?? "Unknown";
    final selectedPrinterType =
        prefs.getString("printer_type") ?? "USB Printer";

    final selectedOption = cartProvider.selectedOption ?? "None";
    final selectedTableId = cartProvider.selectedTableId ?? 0;
    final selectedTableName = cartProvider.selectedTableName ?? "None";

    int kottype = _determineKotType(cartProvider);

    List<Map<String, dynamic>> orderItems = selectedItems.map((item) {
      return _buildOrderItem(item, cartProvider);
    }).toList();

    final url = Uri.parse("https://hotelserver.billhost.co.in/DineinKOT");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderItems),
      );

      if (response.statusCode == 200) {
        await _handleSuccessfulPrintOrder(
            response, orderItems, waiterName, selectedTableName);
        cartProvider.clearCart();
        _navigateToDashboard();
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

  int _determineKotType(CartProvider cartProvider) {
    if (cartProvider.selectedOption == "Table") {
      return cartProvider.selectedTableId != null ? 0 : 1;
    } else if (cartProvider.selectedOption == "Delivery") {
      return 2;
    } else if (cartProvider.selectedOption == "Takeaway") {
      return 3;
    }
    return 0;
  }

  Map<String, dynamic> _buildOrderItem(
      Map<String, dynamic> item, CartProvider cartProvider) {
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
      "rate": (Apphelper()
          .totalgst(item['restrate'], item['cess'], item['gst'],
              Apphelper.gsttype!, quantity)
          .toStringAsFixed(2)),
      "gst": item['gst'],
      "cess": item['cess'],
      //  "itcomment": "",
      "itcomment": cartProvider.getItemComment(item['id']),
      "isdiscountable": 0,
      "id": "",
      "shopid": responseData[0]['shopid'],
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
      "wcode": responseData[0]['id'],
      "wname": responseData[0]['wname'],
      "nop": 1,
      "kottype": _determineKotType(cartProvider),
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
      "totgst": ((item['restrate'] ?? 0) * quantity * 0.05).toStringAsFixed(2),
      "totcess": "0.00",
      "totdiscamt": "0.00",
      "totbldiscamt": "0.00",
      "totalservicechamt":
          ((item['restrate'] ?? 0) * quantity * 0.12).toStringAsFixed(2),
      "roundoff": "0.00",
      "totblamt": ((item['restrate'] ?? 0) * quantity * 1.17).round(),
      "totordamt": ((item['restrate'] ?? 0) * quantity * 1.05).round(),
    };
  }

  void _handleOrderResponse(http.Response response, CartProvider cartProvider) {
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order placed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      cartProvider.clearCart();
      _navigateToDashboard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place order: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSuccessfulPrintOrder(
      http.Response response,
      List<Map<String, dynamic>> orderItems,
      String waiterName,
      String selectedTableName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );

    List<BillItem> orderItemsfinal = [];
    for (int i = 0; i < orderItems.length; i++) {
      orderItemsfinal.add(
        BillItem(
          serialNo: i + 1,
          name: orderItems[i]['itname'] ?? "Unknown",
          quantity: orderItems[i]['qty'] ?? "Unknown",
        ),
      );
    }

    if (Apphelper.printerType == Appstring.bluetoothPrinter) {
      if (Apphelper.connectedDevice != null) {
        await printFormattedBill(
          Apphelper.connectedDevice!,
          "Dine-in",
          "Crossrug",
          "Main",
          response.body.toString(),
          selectedTableName,
          "${TimeOfDay.now().hour}:${TimeOfDay.now().minute} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}",
          "${DateTime.now().day.toString().padLeft(2, '0')}/"
              "${DateTime.now().month.toString().padLeft(2, '0')}/"
              "${(DateTime.now().year % 100).toString().padLeft(2, '0')}",
          waiterName,
          "NOP",
          orderItemsfinal,
        );
      }
    }
  }

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

      List<int> escPosCommands = [];

      // Order Type
      escPosCommands.addAll([0x1B, 0x61, 0x01]);
      escPosCommands.addAll([0x1B, 0x45, 0x01]);
      escPosCommands.addAll(utf8.encode("$orderType\n"));
      escPosCommands.addAll([0x1B, 0x45, 0x00]);
      escPosCommands.addAll([0x1B, 0x61, 0x00]);

      // Restaurant Name
      escPosCommands.addAll([0x1B, 0x61, 0x01]);
      escPosCommands.addAll([0x1B, 0x45, 0x01]);
      escPosCommands.addAll(utf8.encode("${restaurantName.toUpperCase()}\n"));
      escPosCommands.addAll([0x1B, 0x45, 0x00]);
      escPosCommands.addAll([0x1B, 0x61, 0x00]);

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

      // Item list
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

      escPosCommands.addAll([0x1D, 0x56, 0x00]);

      Uint8List printData = Uint8List.fromList(escPosCommands);

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            int chunkSize = 237;

            for (int i = 0; i < printData.length; i += chunkSize) {
              int end = (i + chunkSize < printData.length)
                  ? i + chunkSize
                  : printData.length;
              await characteristic.write(printData.sublist(i, end),
                  withoutResponse: true);
              await Future.delayed(Duration(milliseconds: 50));
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

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoardScreen(
          responseData: responseData,
          itemCounts: itemCounts,
          menuItems: menuItems,
          selectedOption: selectedOption,
        ),
      ),
    );
  }
}

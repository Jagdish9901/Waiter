import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String baseUrl = "https://hotelserver.billhost.co.in";
}

class ApiService {
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    String encodedUsername = Uri.encodeComponent(username);
    String encodedPassword = Uri.encodeComponent(password);
    String apiUrl =
        "${ApiConstants.baseUrl}/checkWaiter/$encodedUsername/$encodedPassword";

    try {
      var response = await http.get(Uri.parse(apiUrl));

      developer.log("Response Status Code: ${response.statusCode}");
      developer.log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          return responseData[0]; // Returning first object from the list
        } else {
          return null; // No user found
        }
      } else {
        return null;
      }
    } catch (e) {
      developer.log("Error: $e");
      return null;
    }
  }

  // Future<void> _fetchOrders() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final int? wid = prefs.getInt("wid");
  //   final int? shopid = prefs.getInt("wcode"); // Fetch shopid dynamically
  //   // print("Retrieved Waiter ID: $wid"); // Debugging line
  //   // print("retrieved shopo id ; $shopid");

  //   if (wid == null || wid == 0 || shopid == null || shopid == 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content:
  //               Text("Shop ID or Waiter ID not found. Please log in again.")),
  //     );
  //     return;
  //   }
  //   // final int? shopid = prefs.getInt("wcode");
  //   String fromDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  //   String toDate = fromDate;

  //   final url = Uri.parse(
  //       "https://hotelserver.billhost.co.in/kotviewWaiter/$shopid/$fromDate/$toDate/$wid");
  //   print(url);

  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // print("API Response: $data"); // Debugging - Print full response

  //       if (data != null && data is List) {
  //         setState(() {
  //           orders = data;
  //         });
  //         print(orders);
  //       } else {
  //         setState(() {
  //           orders = [];
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("No order data found.")),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to fetch orders: ${response.body}")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error fetching orders: $e")),
  //     );
  //   }
  // }
}

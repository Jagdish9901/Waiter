// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiConstants {
//   static const String baseUrl = "https://hotelserver.billhost.co.in";
// }

// class ApiService {
//   static Future<Map<String, dynamic>?> login(
//       String username, String password) async {
//     String encodedUsername = Uri.encodeComponent(username);
//     String encodedPassword = Uri.encodeComponent(password);
//     String apiUrl =
//         "${ApiConstants.baseUrl}/checkWaiter/$encodedUsername/$encodedPassword";

//     try {
//       var response = await http.get(Uri.parse(apiUrl));

//       developer.log("Response Status Code: ${response.statusCode}");
//       developer.log("Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);

//         if (responseData.isNotEmpty) {
//           return responseData[0]; // Returning first object from the list
//         } else {
//           return null; // No user found
//         }
//       } else {
//         return null;
//       }
//     } catch (e) {
//       developer.log("Error: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = "https://hotelserver.billhost.co.in";

  // Helper method to get shared preferences
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Order History Related Methods
  Future<List<dynamic>> fetchOrders({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final prefs = await _prefs;
    final int? wid = prefs.getInt("wid");
    final int? shopid = prefs.getInt("wcode");

    if (wid == null || wid == 0 || shopid == null || shopid == 0) {
      throw Exception("Shop ID or Waiter ID not found. Please log in again.");
    }

    String formattedFromDate = _formatDate(fromDate);
    String formattedToDate = _formatDate(toDate);

    final url = Uri.parse(
        "$baseUrl/kotviewWaiter/$shopid/$formattedFromDate/$formattedToDate/$wid");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          return data;
        }
      }
      throw Exception("Failed to fetch orders: ${response.statusCode}");
    } catch (e) {
      throw Exception("Error fetching orders: $e");
    }
  }

  Future<void> cancelOrder({
    required String shopvno,
    required String tablecode,
    required String reason,
  }) async {
    final prefs = await _prefs;
    final int? shopid = prefs.getInt("wcode");

    if (shopid == null || shopid == 0) {
      throw Exception("Shop ID not found. Please log in again.");
    }

    final url =
        Uri.parse("$baseUrl/CancelOrder/$shopid/$shopvno/$tablecode/$reason");

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel order: ${response.body}");
    }
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

// Table transfer related api
  Future<List<Map<String, dynamic>>> fetchOccupiedTables() async {
    final prefs = await _prefs;
    final int? shopid = prefs.getInt("wcode");

    final url = Uri.parse("$baseUrl/$shopid/table/1");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load occupied tables');
  }

  Future<List<Map<String, dynamic>>> fetchAvailableTables() async {
    final prefs = await _prefs;
    final int? shopid = prefs.getInt("wcode");

    final url = Uri.parse("$baseUrl/$shopid/table/0");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load available tables');
  }

  Future<void> transferTable({
    required String fromId,
    required String toId,
    required String toName,
    required String nop,
    required String wcode,
    required String wname,
  }) async {
    final prefs = await _prefs;
    final int? usershopid = prefs.getInt("wcode");

    final url = Uri.parse(
        "$baseUrl/tabletrf/$usershopid/$fromId/$toId/$toName/$nop/$wcode/$wname");

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to transfer table');
    }
  }
}

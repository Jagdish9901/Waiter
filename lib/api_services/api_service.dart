import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/models/notification_item.dart';
import 'package:waiter_app/providers/notification_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = "https://hotelserver.billhost.co.in";
  Timer? _notificationTimer;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  //---------------- Order History Methods ----------------

  Future<List<Map<String, dynamic>>> fetchOrders({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final prefs = await _prefs;
      final shopId = prefs.getInt('wcode')?.toString() ?? '0';
      final waiterId = prefs.getInt('wid')?.toString() ?? '0';

      if (shopId == '0' || waiterId == '0') {
        throw Exception('Shop ID or Waiter ID not available');
      }

      final formattedFromDate = _formatDate(fromDate);
      final formattedToDate = _formatDate(toDate);
      // debugPrint('   From: $formattedFromDate');
      // debugPrint('   To: $formattedToDate');

      final url = Uri.parse(
          '$baseUrl/kotviewWaiter/$shopId/$formattedFromDate/$formattedToDate/$waiterId');
      // debugPrint(' API URL: $url');

      final response = await http.get(url);
      // debugPrint(' Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // debugPrint(' Received ${data.length} orders');
        return List<Map<String, dynamic>>.from(data);
      } else {
        // debugPrint(' API Error: ${response.body}');
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      // debugPrint(' Error in fetchOrders: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder({
    required String shopvno,
    required String tablecode,
    required String reason,
  }) async {
    // debugPrint('\n CANCELLING ORDER');
    try {
      final prefs = await _prefs;
      final shopId = prefs.getInt('wcode')?.toString() ?? '0';

      // debugPrint('   Order #: $shopvno');
      // debugPrint('   Table: $tablecode');
      // debugPrint('   Reason: $reason');

      if (shopId == '0') {
        // debugPrint(' ERROR: Invalid Shop ID');
        throw Exception('Shop ID not available');
      }

      final url =
          Uri.parse('$baseUrl/CancelOrder/$shopId/$shopvno/$tablecode/$reason');
      // debugPrint(' API URL: $url');

      final response = await http.post(url);
      // debugPrint(' Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
      // debugPrint(' Order cancelled successfully');
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- Notification Service ----------------

  void startNotificationPolling(BuildContext context) {
    // debugPrint('\n STARTING NOTIFICATION POLLING SYSTEM');
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkForReadyOrders(context);
    });
    _checkForReadyOrders(context);
  }

  void stopNotificationPolling() {
    // debugPrint('\n STOPPING NOTIFICATION POLLING');
    _notificationTimer?.cancel();
  }

// notification not showing after logout

  Future<void> _checkForReadyOrders(BuildContext context) async {
    try {
      final prefs = await _prefs;
      final shopId = prefs.getInt('wcode')?.toString() ?? '0';
      final waiterId = prefs.getInt('wid')?.toString() ?? '0';

      if (shopId == '0' || waiterId == '0') return;

      final now = DateTime.now();
      final formattedDate = _formatDate(now);

      final urls = [
        Uri.parse(
            '$baseUrl/kotviewWaiter/$shopId/$formattedDate/$formattedDate/$waiterId'),
      ];

      final provider =
          Provider.of<NotificationProvider>(context, listen: false);
      final processedOrders =
          provider.notifications.map((n) => n.orderNo).toSet();

      for (final url in urls) {
        try {
          final response = await http.get(url);

          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            for (final item in data) {
              final kotMasDTO = item['kotMasDTO'];
              if (kotMasDTO != null && kotMasDTO['kdsstatus'] == 0) {
                final kotWaiterCode = kotMasDTO['wcode']?.toString();
                if (kotWaiterCode == waiterId) {
                  final orderNo = kotMasDTO['shopvno'].toString();

                  // Only check if we haven't processed this order before
                  if (!processedOrders.contains(orderNo)) {
                    final itemName = kotMasDTO['itname'] ?? 'Unknown Item';
                    final tableName = item['tablename'] ?? 'Unknown Table';

                    provider.addNotification(
                      NotificationItem(
                        orderNo: orderNo,
                        itemName: itemName,
                        tableName: tableName,
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                }
              }
            }
          }
        } catch (e) {
          debugPrint('API Error: $e');
        }
      }
    } catch (e) {
      debugPrint('System Error: $e');
    }
  }

  // Future<void> _checkForReadyOrders(BuildContext context) async {
  //   try {
  //     final prefs = await _prefs;
  //     final shopId = prefs.getInt('wcode')?.toString() ?? '0';
  //     final waiterId = prefs.getInt('wid')?.toString() ?? '0';

  //     if (shopId == '0' || waiterId == '0') return;

  //     final now = DateTime.now();
  //     final formattedDate = _formatDate(now);

  //     final urls = [
  //       Uri.parse(
  //           '$baseUrl/kotviewWaiter/$shopId/$formattedDate/$formattedDate/$waiterId'),
  //     ];

  //     final provider =
  //         Provider.of<NotificationProvider>(context, listen: false);
  //     final processedOrders =
  //         provider.notifications.map((n) => n.orderNo).toSet();

  //     for (final url in urls) {
  //       try {
  //         final response = await http.get(url);
  //         // debugPrint('API Called _checkForReadyOrders: ${url.toString()}');

  //         if (response.statusCode == 200) {
  //           final List<dynamic> data = jsonDecode(response.body);
  //           for (final item in data) {
  //             final kotMasDTO = item['kotMasDTO'];
  //             if (kotMasDTO != null && kotMasDTO['kdsstatus'] == 0) {
  //               final kotWaiterCode = kotMasDTO['wcode']?.toString();
  //               if (kotWaiterCode == waiterId) {
  //                 final orderNo = kotMasDTO['shopvno'].toString();
  //                 if (!processedOrders.contains(orderNo)) {
  //                   final itemName = kotMasDTO['itname'] ?? 'Unknown Item';
  //                   final tableName = item['tablename'] ?? 'Unknown Table';

  //                   provider.addNotification(
  //                     NotificationItem(
  //                       orderNo: orderNo,
  //                       itemName: itemName,
  //                       tableName: tableName,
  //                       timestamp: DateTime.now(),
  //                     ),
  //                   );
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         debugPrint('API Error: $e');
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('System Error: $e');
  //   }
  // }

  // ---------------- Table Transfer Methods ----------------

  Future<List<Map<String, dynamic>>> fetchOccupiedTables() async {
    final prefs = await _prefs;
    final shopid = prefs.getInt("wcode") ?? 0;
    final url = Uri.parse("$baseUrl/$shopid/table/1");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load occupied tables');
  }

  Future<List<Map<String, dynamic>>> fetchAvailableTables() async {
    final prefs = await _prefs;
    final shopid = prefs.getInt("wcode") ?? 0;
    final url = Uri.parse("$baseUrl/$shopid/table/0");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
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
    final usershopid = prefs.getInt("wcode") ?? 0;
    final url = Uri.parse(
        "$baseUrl/tabletrf/$usershopid/$fromId/$toId/$toName/$nop/$wcode/$wname");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to transfer table: ${response.body}');
    }
  }

  // ---------------- Helper Methods ----------------

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void dispose() {
    _notificationTimer?.cancel();
  }
}

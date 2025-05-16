import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:waiter_app/OrderModification.dart';
import 'package:waiter_app/api_services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> orders = [];
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  bool isInitiallyExpanded = true;
  bool showErrorBorder = false;

  final ScrollController _scrollController = ScrollController();
  bool _showDateRow = true;
  double _lastOffset = 0;

  Timer? _orderRefreshTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchOrders();

    // Repeated fetch every 4 seconds
    _orderRefreshTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      _fetchOrders();
    });

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    double currentOffset = _scrollController.offset;

    if (currentOffset > _lastOffset && _showDateRow) {
      // Scrolling down
      setState(() => _showDateRow = false);
    } else if (currentOffset < _lastOffset && !_showDateRow) {
      // Scrolling up
      setState(() => _showDateRow = true);
    }
    _lastOffset = currentOffset;
  }

  @override
  void dispose() {
    _orderRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final data =
          await _apiService.fetchOrders(fromDate: fromDate, toDate: toDate);
      setState(() => orders = data);

      // for (int i = 0; i < orders.length; i++) {
      //   if (orders[i]["kotMasDTO"] != null) {
      //     if (orders[i]["kotMasDTO"]["kdsstatus"].toString().toLowerCase() ==
      //         "0") {
      //       print("object $i ok");
      //       await showLocalNotification(
      //           orders[i]["kotMasDTO"]["shopvno"].toString());
      //       print("object showLocalNotification $i");
      //     }
      //   }
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() => orders = []);
    }
  }

  Future<void> _cancelOrder({
    required String shopvno,
    required String tablecode,
    required String reason,
  }) async {
    try {
      await _apiService.cancelOrder(
        shopvno: shopvno,
        tablecode: tablecode,
        reason: reason,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order cancelled successfully.")),
      );
      _fetchOrders(); // refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Map<String, List<dynamic>> _groupOrdersByShopvno() {
    Map<String, List<dynamic>> groupedOrders = {};
    for (var order in orders) {
      String shopvno = order['kotMasDTO']?['shopvno']?.toString() ?? "Unknown";
      if (!groupedOrders.containsKey(shopvno)) {
        groupedOrders[shopvno] = [];
      }
      groupedOrders[shopvno]!.add(order);
    }
    return groupedOrders;
  }

  void _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedOrders = _groupOrdersByShopvno();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFFFB300),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB300),
              Color(0xFFFFC107),
              Color(0xFFFFE082),
            ],
          ),
        ),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _showDateRow
                  ? Padding(
                      key: ValueKey("dateRow"),
                      padding: EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Text(
                            "From: ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(fromDate),
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(Icons.calendar_today, size: 16),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            "To: ",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(toDate),
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(Icons.calendar_today, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Expanded(
              child: groupedOrders.isEmpty
                  ? Center(child: Text("No orders found"))
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      children: groupedOrders.entries.map((entry) {
                        String shopvno = entry.key;
                        List<dynamic> shopOrders = entry.value;

                        bool isCancelled = shopOrders.any((order) =>
                            order['kotMasDTO']?['status']?.toString() == '2');

                        final int kottype =
                            shopOrders[0]['kotMasDTO']?['kottype'] ?? 0;
                        final String? tableNumber = shopOrders[0]['kotMasDTO']
                                    ?['tablename']
                                ?.toString() ??
                            '';
                        String tableText;
                        if (kottype == 2) {
                          tableText = "Delivery";
                        } else if (kottype == 3) {
                          tableText = "Takeaway";
                        } else {
                          tableText = "Table: $tableNumber";
                        }

                        return Card(
                          margin: EdgeInsets.only(top: 8.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        tableText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Order No: $shopvno',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 9),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "Time: ${shopOrders[0]['kotMasDTO']?['kottime'] ?? ''}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                if (isCancelled)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 16.0, bottom: 4.0, top: 12.0),
                                    child: Text(
                                      "Order Cancelled",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ...shopOrders.map((order) {
                                  final String itemName = order['kotMasDTO']
                                              ?['itname']
                                          ?.toString() ??
                                      "Unknown Item";
                                  final String quantity =
                                      order['kotMasDTO']?['qty']?.toString() ??
                                          "0";
                                  final bool isCancelled =
                                      double.tryParse(quantity) == 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(itemName,
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: isCancelled
                                                    ? Colors.red
                                                    : null)),
                                        Text("Qty: $quantity",
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: isCancelled
                                                    ? Colors.red
                                                    : null)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Opacity(
                                        opacity: isCancelled ? 0.5 : 1.0,
                                        child: IgnorePointer(
                                          ignoring: isCancelled,
                                          child: SizedBox(
                                            height: 4.5.h,
                                            width: 23.w,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    String reason = '';
                                                    final TextEditingController
                                                        reasonController =
                                                        TextEditingController();
                                                    final FocusNode
                                                        reasonFocusNode =
                                                        FocusNode();
                                                    return StatefulBuilder(
                                                      builder: (context,
                                                          setStateDialog) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Cancel Order"),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                "Why are you cancelling this order?",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 1.h),
                                                              TextField(
                                                                controller:
                                                                    reasonController,
                                                                focusNode:
                                                                    reasonFocusNode,
                                                                onChanged:
                                                                    (value) {
                                                                  reason =
                                                                      value;
                                                                  if (value
                                                                      .trim()
                                                                      .isNotEmpty) {
                                                                    setStateDialog(
                                                                        () {
                                                                      showErrorBorder =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                                maxLines: 3,
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      "Enter your reason here...",
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: showErrorBorder
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .grey,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: showErrorBorder
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .blue,
                                                                      width:
                                                                          0.5.w,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                if (reasonController
                                                                    .text
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  setStateDialog(
                                                                      () {
                                                                    showErrorBorder =
                                                                        true;
                                                                  });
                                                                  Future
                                                                      .delayed(
                                                                    Duration(
                                                                        milliseconds:
                                                                            100),
                                                                    () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .requestFocus(
                                                                              reasonFocusNode);
                                                                    },
                                                                  );
                                                                  return;
                                                                }
                                                                String
                                                                    cancelReason =
                                                                    reasonController
                                                                        .text
                                                                        .trim();
                                                                String?
                                                                    tablecode;
                                                                if (shopOrders
                                                                        .isNotEmpty &&
                                                                    shopOrders.first[
                                                                            'kotMasDTO'] !=
                                                                        null &&
                                                                    shopOrders.first['kotMasDTO']
                                                                            [
                                                                            'tablecode'] !=
                                                                        null) {
                                                                  tablecode = shopOrders
                                                                      .first[
                                                                          'kotMasDTO']
                                                                          [
                                                                          'tablecode']
                                                                      .toString();
                                                                }
                                                                if (tablecode ==
                                                                        null ||
                                                                    tablecode
                                                                        .isEmpty) {
                                                                  return;
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                                await _cancelOrder(
                                                                  shopvno:
                                                                      shopvno,
                                                                  tablecode:
                                                                      tablecode,
                                                                  reason:
                                                                      cancelReason,
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                  "Confirm",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                textStyle:
                                                    TextStyle(fontSize: 14.sp),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Void",
                                                style: TextStyle(
                                                    fontSize: 14.3.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Opacity(
                                        opacity: isCancelled ? 0.5 : 1.0,
                                        child: IgnorePointer(
                                          ignoring: isCancelled,
                                          child: SizedBox(
                                            height: 4.5.h,
                                            width: 23.w,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderModificationScreen(
                                                      shopvno: shopvno,
                                                      shopOrders: shopOrders,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                textStyle:
                                                    TextStyle(fontSize: 14.sp),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Modify",
                                                style: TextStyle(
                                                    fontSize: 14.3.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// class OrderModificationScreen extends StatefulWidget {
//   final String shopvno;
//   final List<dynamic> shopOrders;

//   OrderModificationScreen({required this.shopvno, required this.shopOrders});

//   @override
//   _OrderModificationScreenState createState() =>
//       _OrderModificationScreenState();
// }

// class _OrderModificationScreenState extends State<OrderModificationScreen> {
//   Map<int, int> itemQuantities = {};
//   Map<int, String> cancellationReasons = {}; // Store cancellation reasons

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i < widget.shopOrders.length; i++) {
//       itemQuantities[i] =
//           int.tryParse(widget.shopOrders[i]['kotMasDTO']['qty'].toString()) ??
//               0;
//     }
//   }

//   void _decreaseQty(int index) {
//     final currentQty = itemQuantities[index]!;
//     if (currentQty == 1) {
//       _showCancelDialog(index);
//     } else {
//       setState(() {
//         itemQuantities[index] = currentQty - 1;
//       });
//     }
//   }

//   void _increaseQty(int index) {
//     setState(() {
//       itemQuantities[index] = itemQuantities[index]! + 1;
//     });
//   }

//   void _showCancelDialog(int index) {
//     String reason = '';
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Cancel Item"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Why do you want to cancel this item ?"),
//               SizedBox(height: 16),
//               TextField(
//                 onChanged: (value) {
//                   reason = value;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Enter reason for cancellation...",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white),
//               onPressed: () => Navigator.pop(context),
//               child: Text("No"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white),
//               onPressed: () {
//                 setState(() {
//                   itemQuantities[index] = 0;
//                   cancellationReasons[index] = reason;
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text("Yes, Cancel"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFFFFB300),
//         title: Text('Modify Order No. ${widget.shopvno}'),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//               Color(0xFFFFB300),
//               Color(0xFFFFC107),
//               Color(0xFFFFE082),
//             ])),
//         child: Column(
//           children: [
//             Expanded(
//               // Use Expanded to make the ListView take up available vertical space
//               child: ListView.builder(
//                 padding: EdgeInsets.all(16),
//                 itemCount: widget.shopOrders.length,
//                 itemBuilder: (context, index) {
//                   // Skip showing cancelled items
//                   if (itemQuantities[index] == 0) return SizedBox.shrink();

//                   final order = widget.shopOrders[index];
//                   final itemName =
//                       order['kotMasDTO']?['itname'] ?? "Unknown Item";

//                   return Card(
//                     margin: EdgeInsets.only(bottom: 12),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(itemName,
//                                 style: TextStyle(fontSize: 15.sp)),
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                 color: Colors.red,
//                                 icon: Icon(Icons.remove_circle_outline),
//                                 onPressed: () => _decreaseQty(index),
//                               ),
//                               Text(
//                                 itemQuantities[index].toString(),
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               IconButton(
//                                 color: Colors.green,
//                                 icon: Icon(Icons.add_circle_outline),
//                                 onPressed: () => _increaseQty(index),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(12),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(
//                       vertical: 14), // Keep some internal padding
//                   fixedSize: Size(150, 40), // Set a specific width and height
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text("Update Order",
//                     style: TextStyle(fontSize: 15.sp, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';

class OrderModificationScreen extends StatefulWidget {
  final String shopvno;
  final List<dynamic> shopOrders;

  OrderModificationScreen({required this.shopvno, required this.shopOrders});

  @override
  _OrderModificationScreenState createState() =>
      _OrderModificationScreenState();
}

class _OrderModificationScreenState extends State<OrderModificationScreen> {
  Map<int, int> itemQuantities = {};
  Map<int, String> cancellationReasons = {}; // Store cancellation reasons

  @override
  void initState() {
    itemQuantitiesadd();
    super.initState();
  }

  itemQuantitiesadd() {
    for (int i = 0; i < widget.shopOrders.length; i++) {
      itemQuantities[i] =
          double.tryParse(widget.shopOrders[i]['kotMasDTO']['qty'].toString())
                  ?.toInt() ??
              0;
    }
    // if (mounted) setState(() {});
  }

  void _decreaseQty(int index) {
    final currentQty = itemQuantities[index]!;
    if (currentQty == 1) {
      _showCancelDialog(index);
    } else {
      setState(() {
        itemQuantities[index] = currentQty - 1;
      });
    }
  }

  void _increaseQty(int index) {
    setState(() {
      itemQuantities[index] = itemQuantities[index]! + 1;
    });
  }

  void _showCancelDialog(int index) {
    String reason = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cancel Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Why do you want to cancel this item ?"),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  reason = value;
                },
                decoration: InputDecoration(
                  hintText: "Enter reason for cancellation...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  itemQuantities[index] = 0;
                  cancellationReasons[index] = reason;
                });
                Navigator.pop(context);
              },
              child: Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateOrder() async {
    List<Map<String, dynamic>> updatedOrderList = [];

    for (int index = 0; index < widget.shopOrders.length; index++) {
      final original = widget.shopOrders[index]['kotMasDTO'];
      if (original == null) continue;

      // Clone and modify the original item
      Map<String, dynamic> modifiedItem = Map<String, dynamic>.from(original);

      int newQty = itemQuantities[index] ?? modifiedItem['qty'];
      String reason = cancellationReasons[index] ?? "";

      modifiedItem['qty'] = newQty;
      modifiedItem['itcomment'] = reason;

      updatedOrderList.add(modifiedItem);
    }

    try {
      final response = await http.put(
        Uri.parse("https://hotelserver.billhost.co.in/DineinKOTItemTRF"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedOrderList),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order')),
        );
      }
    } catch (e) {
      print("Error updating order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFB300),
        title: Text('Modify Order No. ${widget.shopvno}'),
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
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
                itemCount: widget.shopOrders.length,
                itemBuilder: (context, index) {
                  if (itemQuantities[index] == 0) return SizedBox.shrink();

                  final order = widget.shopOrders[index];
                  final itemName =
                      order['kotMasDTO']?['itname'] ?? "Unknown Item";

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(itemName,
                                style: TextStyle(fontSize: 15.sp)),
                          ),
                          Row(
                            children: [
                              IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () => _decreaseQty(index),
                              ),
                              Text(
                                itemQuantities[index].toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                color: Colors.green,
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () => _increaseQty(index),
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
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: updateOrder,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  fixedSize: Size(120, 50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Update Order",
                    style: TextStyle(fontSize: 15.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';

// class DishesScreen extends StatefulWidget {
//   final List<dynamic> dishes;
//   final Map<int, int> cartItems;
//   final Function(int, int) onItemCountChanged;

//   const DishesScreen({
//     Key? key,
//     required this.dishes,
//     required this.cartItems,
//     required this.onItemCountChanged,
//   }) : super(key: key);

//   @override
//   State<DishesScreen> createState() => _DishesScreenState();
// }

// class _DishesScreenState extends State<DishesScreen> {
//   List<dynamic> items = [];
//   bool isLoading = false;
//   Map<int, int> itemCounts = {}; // Store item counts

//   @override
//   void initState() {
//     super.initState();
//     // Request Bluetooth permissions
//     Future<void> _requestPermissions() async {
//       await Permission.bluetooth.request();
//       await Permission.bluetoothScan.request();
//       await Permission.bluetoothConnect.request();
//       await Permission.locationWhenInUse.request();
//     }

//     itemCounts = Map<int, int>.from(widget.cartItems); // Copy the cart items
//   }

//   Future<void> _fetchItems(int dishId) async {
//     setState(() {
//       isLoading = true;
//       items.clear(); // Clear previous items
//       itemCounts.clear(); // Clear previous counts
//     });

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://hotelserver.billhost.co.in/ItemSearchBydtcode/1/$dishId'),
//       );

//       if (response.statusCode == 200) {
//         final decodedData = jsonDecode(response.body);
//         setState(() {
//           items = decodedData;
//           for (var item in items) {
//             itemCounts[item['itid']] = 0; // Initialize count to 0
//           }
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to load items")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error fetching items")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Dishes")),
//       body: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height,
//               width: 200,
//               child: ListView.builder(
//                 itemCount: widget.dishes.length,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       _fetchItems(widget.dishes[index]['id']);
//                     },
//                     child: Card(
//                       margin: const EdgeInsets.all(10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           widget.dishes[index]['dhname'],
//                           style: const TextStyle(
//                               fontSize: 12, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const VerticalDivider(width: 2, color: Colors.black),
//             Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : items.isEmpty
//                       ? const Center(child: Text("Select a dish to view items"))
//                       : Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: GridView.builder(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                               childAspectRatio: 1.0,
//                             ),
//                             itemCount: items.length,
//                             itemBuilder: (context, index) {
//                               final itemId = items[index]['itid'];
//                               return Card(
//                                 elevation: 3,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Stack(
//                                     children: [
//                                       Center(
//                                         child: Text(
//                                           items[index]['itname'],
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment: Alignment.bottomRight,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Text(
//                                             "₹${items[index]['restrate']}",
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         left: 4,
//                                         bottom: 2,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 5, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     if (itemCounts[itemId] !=
//                                                             null &&
//                                                         itemCounts[itemId]! >
//                                                             0) {
//                                                       itemCounts[itemId] =
//                                                           (itemCounts[itemId] ??
//                                                                   0) -
//                                                               1;
//                                                     }
//                                                   });
//                                                 },
//                                                 child: const Icon(Icons.remove,
//                                                     size: 12,
//                                                     color: Colors.white),
//                                               ),
//                                               Text(
//                                                 itemCounts[itemId]
//                                                         ?.toString() ??
//                                                     "0",
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     itemCounts[itemId] =
//                                                         (itemCounts[itemId] ??
//                                                                 0) +
//                                                             1;
//                                                   });
//                                                 },
//                                                 child: const Icon(Icons.add,
//                                                     size: 12,
//                                                     color: Colors.white),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 18),
//                   ),
//                   child: const Text("Place Order"),
//                 ),
//               ),
//               Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.shopping_cart,
//                         size: 35, color: Colors.black),
//                     onPressed: () {},
//                   ),
//                   if (itemCounts.values.any((count) => count > 0))
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: CircleAvatar(
//                         radius: 10,
//                         backgroundColor: Colors.red,
//                         child: Text(
//                           itemCounts.values
//                               .fold(0, (sum, count) => sum + count)
//                               .toString(),
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

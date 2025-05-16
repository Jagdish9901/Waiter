// import 'dart:convert'; // Import for jsonEncode/Decode
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

// class CartProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _cartItems = [];
//   Map<int, int> _itemCounts = {}; // Stores item IDs and their quantities
//   String? _selectedOption; // Stores selected option (Delivery, Takeaway, Table)
//   String _selectedTableName = ""; // Stores selected table name (default empty)
//   int? _selectedTableId; // Stores selected table ID

//   // --- SharedPreferences Keys ---
//   static const String _cartItemsKey = 'cartItems';
//   static const String _itemCountsKey = 'itemCounts';
//   static const String _selectedOptionKey = 'selectedOption';
//   static const String _selectedTableNameKey = 'selectedTableName';
//   static const String _selectedTableIdKey = 'selectedTableId';

//   // --- Getters ---
//   List<Map<String, dynamic>> get cartItems => _cartItems;
//   Map<int, int> get itemCounts => _itemCounts;
//   String? get selectedOption => _selectedOption;
//   String get selectedTableName =>
//       _selectedTableName; // Return empty string if null
//   int? get selectedTableId => _selectedTableId;

//   int get totalItemsCount =>
//       _itemCounts.values.fold(0, (sum, count) => sum + count);

//   // --- Initialization ---
//   // Call this method when your app starts, before accessing the provider
//   Future<void> init() async {
//     await _loadCart();
//     log('CartProvider initialized and loaded from storage.');
//   }

//   // --- Cart Modification Methods ---
//   Future<void> addToCart(Map<String, dynamic> item) async {
//     int itemId = item['id'];
//     if (_itemCounts.containsKey(itemId)) {
//       _itemCounts[itemId] = _itemCounts[itemId]! + 1;
//     } else {
//       _itemCounts[itemId] = 1;
//       // Only add the item details if it's the first time
//       _cartItems.add(item);
//     }
//     await _saveCart(); // Save after modification
//     notifyListeners();
//   }

//   Future<void> removeFromCart(Map<String, dynamic> item) async {
//     int itemId = item['id'];
//     if (_itemCounts.containsKey(itemId)) {
//       if (_itemCounts[itemId]! > 1) {
//         _itemCounts[itemId] = _itemCounts[itemId]! - 1;
//       } else {
//         _itemCounts.remove(itemId);
//         _cartItems.removeWhere((cartItem) => cartItem['id'] == itemId);
//       }
//       await _saveCart(); // Save after modification
//       notifyListeners();
//     }
//   }

//   Future<void> clearCart() async {
//     _cartItems.clear();
//     _itemCounts.clear();
//     _selectedOption = null;
//     _selectedTableName = ''; // Reset table name
//     _selectedTableId = null;
//     await _saveCart(); // Save after clearing
//     notifyListeners();
//   }

//   // --- Option/Table Setting Methods ---
//   Future<void> setSelectedOption(String option) async {
//     _selectedOption = option;
//     if (option != "Table") {
//       _selectedTableName =
//           ""; // Clear table name if switching away from "Table"
//       _selectedTableId = null;
//     }
//     await _saveCart(); // Save after modification
//     notifyListeners();
//   }

//   Future<void> setSelectedTable(int tableId, String tableName) async {
//     _selectedTableId = tableId;
//     _selectedTableName = tableName;
//     _selectedOption = "Table"; // Ensure option is set to "Table"
//     await _saveCart(); // Save after modification
//     notifyListeners();
//   }

//   // --- Persistence Logic (Private) ---

//   Future<void> _saveCart() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Serialize cartItems list to JSON string
//       final String encodedCartItems = jsonEncode(_cartItems);
//       await prefs.setString(_cartItemsKey, encodedCartItems);

//       // Serialize itemCounts map to JSON string (convert int keys to String)
//       final Map<String, int> stringKeyItemCounts =
//           _itemCounts.map((key, value) => MapEntry(key.toString(), value));
//       final String encodedItemCounts = jsonEncode(stringKeyItemCounts);
//       await prefs.setString(_itemCountsKey, encodedItemCounts);

//       // Save other simple values
//       if (_selectedOption != null) {
//         await prefs.setString(_selectedOptionKey, _selectedOption!);
//       } else {
//         await prefs.remove(_selectedOptionKey); // Remove if null
//       }

//       await prefs.setString(_selectedTableNameKey, _selectedTableName);

//       if (_selectedTableId != null) {
//         await prefs.setInt(_selectedTableIdKey, _selectedTableId!);
//       } else {
//         await prefs.remove(_selectedTableIdKey); // Remove if null
//       }
//       log('Cart saved successfully.');
//     } catch (e) {
//       log('Error saving cart: $e');
//       // Handle saving error (e.g., show a message to the user)
//     }
//   }

//   Future<void> _loadCart() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Load and deserialize cartItems
//       final String? encodedCartItems = prefs.getString(_cartItemsKey);
//       if (encodedCartItems != null && encodedCartItems.isNotEmpty) {
//         final List<dynamic> decodedCartItems = jsonDecode(encodedCartItems);
//         // Ensure correct type after decoding
//         _cartItems = decodedCartItems
//             .map((item) => Map<String, dynamic>.from(item))
//             .toList();
//         log('Loaded cart items: $_cartItems');
//       } else {
//         _cartItems = []; // Initialize if nothing saved
//       }

//       // Load and deserialize itemCounts
//       final String? encodedItemCounts = prefs.getString(_itemCountsKey);
//       if (encodedItemCounts != null && encodedItemCounts.isNotEmpty) {
//         final Map<String, dynamic> decodedStringKeyItemCounts =
//             jsonDecode(encodedItemCounts);
//         // Convert String keys back to int keys
//         _itemCounts = decodedStringKeyItemCounts
//             .map((key, value) => MapEntry(int.parse(key), value as int));
//         log('Loaded item counts: $_itemCounts');
//       } else {
//         _itemCounts = {}; // Initialize if nothing saved
//       }

//       // Load other simple values
//       _selectedOption = prefs.getString(_selectedOptionKey);
//       _selectedTableName = prefs.getString(_selectedTableNameKey) ??
//           ""; // Default to empty string
//       _selectedTableId = prefs.getInt(_selectedTableIdKey); // Can be null

//       log('Loaded selectedOption: $_selectedOption');
//       log('Loaded selectedTableName: $_selectedTableName');
//       log('Loaded selectedTableId: $_selectedTableId');
//     } catch (e) {
//       log('Error loading cart: $e');
//       _cartItems = [];
//       _itemCounts = {};
//       _selectedOption = null;
//       _selectedTableName = "";
//       _selectedTableId = null;
//       notifyListeners(); // Notify UI about the cleared state due to error
//     }
//   }
// }

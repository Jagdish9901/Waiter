import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  Map<int, int> _itemCounts = {}; // Stores item IDs and their quantities
  String? _selectedOption; // Stores selected option (Delivery, Takeaway, Table)
  String _selectedTableName = ""; // Stores selected table name (default empty)
  int? _selectedTableId; // Stores selected table ID

  List<Map<String, dynamic>> get cartItems => _cartItems;
  Map<int, int> get itemCounts => _itemCounts;
  String? get selectedOption => _selectedOption;
  String get selectedTableName =>
      _selectedTableName; // Return empty string if null
  int? get selectedTableId => _selectedTableId;

  //  Total item count for bottom nav badge
  int get totalItemsCount =>
      _itemCounts.values.fold(0, (sum, count) => sum + count);

  void addToCart(Map<String, dynamic> item) {
    int itemId = item['id'];
    if (_itemCounts.containsKey(itemId)) {
      _itemCounts[itemId] = _itemCounts[itemId]! + 1;
    } else {
      _itemCounts[itemId] = 1;
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> item) {
    int itemId = item['id'];
    if (_itemCounts.containsKey(itemId) && _itemCounts[itemId]! > 1) {
      _itemCounts[itemId] = _itemCounts[itemId]! - 1;
    } else {
      _itemCounts.remove(itemId);
      _cartItems.removeWhere((cartItem) => cartItem['id'] == itemId);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _itemCounts.clear();
    _selectedOption = null;
    _selectedTableName = ''; // Reset table name
    _selectedTableId = null;
    notifyListeners();
  }

  //  Update Selected Option (Table, Delivery, Takeaway)
  void setSelectedOption(String option) {
    _selectedOption = option;
    if (option != "Table") {
      _selectedTableName =
          ""; // Clear table name if switching away from "Table"
      _selectedTableId = null;
    }
    notifyListeners();
  }

  //  Update Selected Table
  void setSelectedTable(int tableId, String tableName) {
    _selectedTableId = tableId;
    _selectedTableName = tableName;
    _selectedOption = "Table"; // Ensure option is set to "Table"
    notifyListeners();
  }
}







// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CartProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _cartItems = [];
//   Map<int, int> _itemCounts = {}; // Stores item IDs and their quantities
//   String? _selectedOption; // Stores selected option (Delivery, Takeaway, Table)
//   String _selectedTableName = ""; // Stores selected table name (default empty)
//   int? _selectedTableId; // Stores selected table ID

//   List<Map<String, dynamic>> get cartItems => _cartItems;
//   Map<int, int> get itemCounts => _itemCounts;
//   String? get selectedOption => _selectedOption;
//   String get selectedTableName => _selectedTableName;
//   int? get selectedTableId => _selectedTableId;

//   // ✅ Total item count for bottom nav badge
//   int get totalItemsCount =>
//       _itemCounts.values.fold(0, (sum, count) => sum + count);

//   CartProvider() {
//     _loadSavedTable(); // Load saved table selection on initialization
//   }

//   void addToCart(Map<String, dynamic> item) {
//     int itemId = item['id'];
//     if (_itemCounts.containsKey(itemId)) {
//       _itemCounts[itemId] = _itemCounts[itemId]! + 1;
//     } else {
//       _itemCounts[itemId] = 1;
//       _cartItems.add(item);
//     }
//     notifyListeners();
//   }

//   void removeFromCart(Map<String, dynamic> item) {
//     int itemId = item['id'];
//     if (_itemCounts.containsKey(itemId) && _itemCounts[itemId]! > 1) {
//       _itemCounts[itemId] = _itemCounts[itemId]! - 1;
//     } else {
//       _itemCounts.remove(itemId);
//       _cartItems.removeWhere((cartItem) => cartItem['id'] == itemId);
//     }
//     notifyListeners();
//   }

//   void clearCart() async {
//     _cartItems.clear();
//     _itemCounts.clear();
//     _selectedOption = null;
//     _selectedTableName = "";
//     _selectedTableId = null;
//     notifyListeners();

//     // ✅ Clear table selection from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("selectedTableId");
//     await prefs.remove("selectedTableName");
//   }

//   // ✅ Update Selected Option (Table, Delivery, Takeaway)
//   void setSelectedOption(String option) {
//     _selectedOption = option;
//     if (option != "Table") {
//       _selectedTableName =
//           ""; // Clear table name if switching away from "Table"
//       _selectedTableId = null;
//     }
//     notifyListeners();
//   }

//   // ✅ Update Selected Table and Save to SharedPreferences
//   void setSelectedTable(int tableId, String tableName) async {
//     _selectedTableId = tableId;
//     _selectedTableName = tableName;
//     _selectedOption = "Table"; // Ensure option is set to "Table"
//     notifyListeners();

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt("selectedTableId", tableId);
//     await prefs.setString("selectedTableName", tableName);
//   }

//   // ✅ Load Selected Table from SharedPreferences on Startup
//   void _loadSavedTable() async {
//     final prefs = await SharedPreferences.getInstance();
//     _selectedTableId = prefs.getInt("selectedTableId");
//     _selectedTableName = prefs.getString("selectedTableName") ?? "";
//     notifyListeners();
//   }
// }


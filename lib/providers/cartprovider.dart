import 'dart:convert'; // Import for jsonEncode/Decode
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  Map<int, int> _itemCounts = {}; // Stores item IDs and their quantities
  Map<int, String> _itemComments = {}; // Stores item-specific comments

  String? _selectedOption;
  String _selectedTableName = '';
  int? _selectedTableId;

  // --- SharedPreferences Keys ---
  static const String _cartItemsKey = 'cartItems';
  static const String _itemCountsKey = 'itemCounts';
  static const String _itemCommentsKey = 'itemComments';
  static const String _selectedOptionKey = 'selectedOption';
  static const String _selectedTableNameKey = 'selectedTableName';
  static const String _selectedTableIdKey = 'selectedTableId';

  // --- Getters ---
  List<Map<String, dynamic>> get cartItems => _cartItems;
  Map<int, int> get itemCounts => _itemCounts;
  String? get selectedOption => _selectedOption;
  String get selectedTableName => _selectedTableName;
  int? get selectedTableId => _selectedTableId;
  int get totalItemsCount =>
      _itemCounts.values.fold(0, (sum, count) => sum + count);

  // Get comment for a specific item
  String getItemComment(int itemId) {
    return _itemComments[itemId] ?? '';
  }

  // Set comment for a specific item
  Future<void> setItemComment(int itemId, String comment) async {
    _itemComments[itemId] = comment;
    await _saveCart();
    notifyListeners();
  }

  // --- Initialization ---
  Future<void> init() async {
    await _loadCart();
    log('CartProvider initialized.');
  }

  // --- Cart Modification ---
  Future<void> addToCart(Map<String, dynamic> item) async {
    final int itemId = item['id'];

    _itemCounts[itemId] = (_itemCounts[itemId] ?? 0) + 1;

    if (!_cartItems.any((element) => element['id'] == itemId)) {
      _cartItems.add(item);
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(Map<String, dynamic> item) async {
    final int itemId = item['id'];

    if (_itemCounts.containsKey(itemId)) {
      if (_itemCounts[itemId]! > 1) {
        _itemCounts[itemId] = _itemCounts[itemId]! - 1;
      } else {
        _itemCounts.remove(itemId);
        _cartItems.removeWhere((element) => element['id'] == itemId);
        _itemComments.remove(itemId); // Also remove the comment
      }

      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _itemCounts.clear();
    _itemComments.clear();
    _selectedOption = null;
    _selectedTableName = '';
    _selectedTableId = null;

    await _saveCart();
    notifyListeners();
  }

  // --- Option/Table Selection ---
  Future<void> setSelectedOption(String option) async {
    _selectedOption = option;

    if (option != "Table") {
      _selectedTableName = '';
      _selectedTableId = null;
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> setSelectedTable(int tableId, String tableName) async {
    _selectedTableId = tableId;
    _selectedTableName = tableName;
    _selectedOption = "Table";

    await _saveCart();
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save cart items
      final String encodedCartItems = jsonEncode(_cartItems);
      await prefs.setString(_cartItemsKey, encodedCartItems);

      // Save item counts
      final Map<String, int> stringKeyItemCounts =
          _itemCounts.map((key, value) => MapEntry(key.toString(), value));
      final String encodedItemCounts = jsonEncode(stringKeyItemCounts);
      await prefs.setString(_itemCountsKey, encodedItemCounts);

      // Save item comments
      final Map<String, String> stringKeyItemComments =
          _itemComments.map((key, value) => MapEntry(key.toString(), value));
      final String encodedItemComments = jsonEncode(stringKeyItemComments);
      await prefs.setString(_itemCommentsKey, encodedItemComments);

      // Save options
      if (_selectedOption != null) {
        await prefs.setString(_selectedOptionKey, _selectedOption!);
      } else {
        await prefs.remove(_selectedOptionKey);
      }

      await prefs.setString(_selectedTableNameKey, _selectedTableName);

      if (_selectedTableId != null) {
        await prefs.setInt(_selectedTableIdKey, _selectedTableId!);
      } else {
        await prefs.remove(_selectedTableIdKey);
      }

      log('Cart saved successfully.');
    } catch (e) {
      log('Error saving cart: $e');
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cart items
      final String? encodedCartItems = prefs.getString(_cartItemsKey);
      if (encodedCartItems != null) {
        final List<dynamic> decoded = jsonDecode(encodedCartItems);
        _cartItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      // Load item counts
      final String? encodedItemCounts = prefs.getString(_itemCountsKey);
      if (encodedItemCounts != null) {
        final Map<String, dynamic> decoded = jsonDecode(encodedItemCounts);
        _itemCounts =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      }

      // Load item comments
      final String? encodedItemComments = prefs.getString(_itemCommentsKey);
      if (encodedItemComments != null) {
        final Map<String, dynamic> decoded = jsonDecode(encodedItemComments);
        _itemComments = decoded
            .map((key, value) => MapEntry(int.parse(key), value as String));
      } else {
        _itemComments = {};
      }

      // Load options
      _selectedOption = prefs.getString(_selectedOptionKey);
      _selectedTableName = prefs.getString(_selectedTableNameKey) ?? '';
      _selectedTableId = prefs.getInt(_selectedTableIdKey);

      log('Cart loaded: $_cartItems');
      log('Counts: $_itemCounts');
      log('Comments: $_itemComments');
      log('Option: $_selectedOption');
      log('Table: $_selectedTableName ($_selectedTableId)');
    } catch (e) {
      log('Error loading cart: $e');
      _cartItems = [];
      _itemCounts = {};
      _itemComments = {};
      _selectedOption = null;
      _selectedTableName = '';
      _selectedTableId = null;
    }

    notifyListeners();
  }
}

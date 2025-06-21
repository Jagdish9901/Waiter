import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/utils/apphelper.dart';

class HomeViewModel with ChangeNotifier {
  // State variables
  int? gstType;
  String? selectedTable;
  List<dynamic> tableData = [];
  bool isLoading = false;
  List<dynamic> itemData = [];
  bool isItemLoading = false;
  List<dynamic> categories = [];
  bool isCategoryLoading = false;
  Map<int, int> itemCounts = {};
  String searchQuery = "";
  int? shopid;
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  List<dynamic> dishTypes = [];
  bool isDishTypeLoading = false;
  int? selectedDishTypeId;

  // Data lists
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> previousDisplayedItems = [];
  bool isSearchActive = false;
  final List<dynamic> responseData;

  HomeViewModel({required this.responseData}) {
    _initialize();
  }

  Future<void> _initialize() async {
    shopid = responseData[0]['shopid'] ?? 0;
    Apphelper.shopid = shopid!;
    await _saveLoginState();
    await shopmasgsttype();
    await fetchTableData(shopid!);
    await _fetchItemData(shopid!);
    await _fetchDishTypes(shopid!);
  }

  Future<void> _saveLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("waiterName", responseData[0]['wname']);
  }

  // In home_viewmodel.dart
  Future<void> fetchTableData(int shopid) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/table'));
      if (response.statusCode == 200) {
        tableData = jsonDecode(response.body);
      } else {
        throw Exception("Failed to load tables");
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchItemData(int shopid) async {
    isItemLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/item'));
      if (response.statusCode == 200) {
        allItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        filteredItems = [];
      } else {
        throw Exception("Failed to load items");
      }
    } catch (e) {
      rethrow;
    } finally {
      isItemLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchDishTypes(int shopid) async {
    try {
      final response = await http.get(
          Uri.parse("https://hotelserver.billhost.co.in/$shopid/Dishtype"));
      if (response.statusCode == 200) {
        dishTypes = json.decode(response.body);
        if (dishTypes.isNotEmpty) {
          selectedCategoryId = dishTypes[0]['id'];
          await _fetchCategories(selectedCategoryId ?? 0, shopid);
        }
      } else {
        throw Exception("Failed to load dish types");
      }
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> shopmasgsttype() async {
    try {
      final gstResponse = await http.get(Uri.parse(
          'https://hotelserver.billhost.co.in/shopmas/${Apphelper.shopid}'));
      if (gstResponse.statusCode == 200) {
        final gstData = jsonDecode(gstResponse.body);
        Apphelper.gsttype = (gstData['gsttype'] == 0) ? false : true;
      }
    } catch (e) {
      // Handle error
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchDishes(int dishTypeId, int shopid) async {
    isItemLoading = true;
    notifyListeners();

    try {
      final url =
          'https://hotelserver.billhost.co.in/ItemSearchBydtcode/$shopid/$dishTypeId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        filteredItems =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load dishes");
      }
    } catch (e) {
      filteredItems = [];
      rethrow;
    } finally {
      isItemLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCategories(int dtId, int shopid) async {
    isCategoryLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          "https://hotelserver.billhost.co.in/finddishtype/$shopid/$dtId"));
      if (response.statusCode == 200) {
        categories = json.decode(response.body);
        if (categories.isNotEmpty) {
          selectedSubCategoryId = categories[0]['id'];
          await _fetchDishes(selectedSubCategoryId ?? 0, shopid);
        }
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      rethrow;
    } finally {
      isCategoryLoading = false;
      notifyListeners();
    }
  }

  void searchItems(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      filteredItems = List.from(previousDisplayedItems);
      isSearchActive = false;
    } else {
      if (!isSearchActive) {
        previousDisplayedItems = List.from(filteredItems);
        isSearchActive = true;
      }
      filteredItems = allItems
          .where((item) => item['itname']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void selectCategory(int id, int shopid) {
    selectedCategoryId = id;
    _fetchCategories(id, shopid);
  }

  void selectSubCategory(int id, int shopid) {
    selectedSubCategoryId = id;
    _fetchDishes(id, shopid);
  }

  String get waiterName =>
      responseData.isNotEmpty ? responseData[0]['wname'] : "Waiter";
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_app/utils/apphelper.dart';

// class HomeViewModel with ChangeNotifier {
//   // State variables
//   int? gstType;
//   String? selectedTable;
//   List<dynamic> tableData = [];
//   bool isLoading = false;
//   List<dynamic> itemData = [];
//   bool isItemLoading = false;
//   List<dynamic> categories = [];
//   bool isCategoryLoading = false;
//   Map<int, int> itemCounts = {};
//   String searchQuery = "";
//   int? shopid;
//   int? selectedCategoryId;
//   int? selectedSubCategoryId;
//   List<dynamic> dishTypes = [];
//   bool isDishTypeLoading = false;
//   int? selectedDishTypeId;

//   // Data lists
//   List<Map<String, dynamic>> allItems = [];
//   List<Map<String, dynamic>> filteredItems = [];
//   List<Map<String, dynamic>> previousDisplayedItems = [];
//   bool isSearchActive = false;

//   // Rotating hint text properties
//   final List<String> rotatingHintTexts = [
//     "roti",
//     "butter roti",
//     "tandoori roti",
//     "samosa",
//     "rasgulla",
//     "paneer tikka",
//     "biryani",
//     "dal makhani",
//   ];
//   int currentHintIndex = 0;
//   Timer? hintRotationTimer;

//   final List<dynamic> responseData;

//   HomeViewModel({required this.responseData}) {
//     _initialize();
//     startHintRotation();
//   }

//   @override
//   void dispose() {
//     hintRotationTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initialize() async {
//     shopid = responseData[0]['shopid'] ?? 0;
//     Apphelper.shopid = shopid!;
//     await _saveLoginState();
//     await shopmasgsttype();
//     await fetchTableData(shopid!);
//     await _fetchItemData(shopid!);
//     await _fetchDishTypes(shopid!);
//   }

//   void startHintRotation() {
//     hintRotationTimer?.cancel();
//     hintRotationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       currentHintIndex = (currentHintIndex + 1) % rotatingHintTexts.length;
//       notifyListeners();
//     });
//   }

//   void stopHintRotation() {
//     hintRotationTimer?.cancel();
//     hintRotationTimer = null;
//   }

//   Future<void> _saveLoginState() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool("isLoggedIn", true);
//     await prefs.setString("waiterName", responseData[0]['wname']);
//   }

//   Future<void> fetchTableData(int shopid) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final response = await http
//           .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/table'));
//       if (response.statusCode == 200) {
//         tableData = jsonDecode(response.body);
//       } else {
//         throw Exception("Failed to load tables");
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _fetchItemData(int shopid) async {
//     isItemLoading = true;
//     notifyListeners();

//     try {
//       final response = await http
//           .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/item'));
//       if (response.statusCode == 200) {
//         allItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//         filteredItems = [];
//       } else {
//         throw Exception("Failed to load items");
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       isItemLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _fetchDishTypes(int shopid) async {
//     try {
//       final response = await http.get(
//           Uri.parse("https://hotelserver.billhost.co.in/$shopid/Dishtype"));
//       if (response.statusCode == 200) {
//         dishTypes = json.decode(response.body);
//         if (dishTypes.isNotEmpty) {
//           selectedCategoryId = dishTypes[0]['id'];
//           await _fetchCategories(selectedCategoryId ?? 0, shopid);
//         }
//       } else {
//         throw Exception("Failed to load dish types");
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       notifyListeners();
//     }
//   }

//   Future<void> shopmasgsttype() async {
//     try {
//       final gstResponse = await http.get(Uri.parse(
//           'https://hotelserver.billhost.co.in/shopmas/${Apphelper.shopid}'));
//       if (gstResponse.statusCode == 200) {
//         final gstData = jsonDecode(gstResponse.body);
//         Apphelper.gsttype = (gstData['gsttype'] == 0) ? false : true;
//       }
//     } catch (e) {
//       // Handle error
//     } finally {
//       notifyListeners();
//     }
//   }

//   Future<void> _fetchDishes(int dishTypeId, int shopid) async {
//     isItemLoading = true;
//     notifyListeners();

//     try {
//       final url =
//           'https://hotelserver.billhost.co.in/ItemSearchBydtcode/$shopid/$dishTypeId';
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         filteredItems =
//             List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       } else {
//         throw Exception("Failed to load dishes");
//       }
//     } catch (e) {
//       filteredItems = [];
//       rethrow;
//     } finally {
//       isItemLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _fetchCategories(int dtId, int shopid) async {
//     isCategoryLoading = true;
//     notifyListeners();

//     try {
//       final response = await http.get(Uri.parse(
//           "https://hotelserver.billhost.co.in/finddishtype/$shopid/$dtId"));
//       if (response.statusCode == 200) {
//         categories = json.decode(response.body);
//         if (categories.isNotEmpty) {
//           selectedSubCategoryId = categories[0]['id'];
//           await _fetchDishes(selectedSubCategoryId ?? 0, shopid);
//         }
//       } else {
//         throw Exception("Failed to load categories");
//       }
//     } catch (e) {
//       rethrow;
//     } finally {
//       isCategoryLoading = false;
//       notifyListeners();
//     }
//   }

//   void searchItems(String query) {
//     searchQuery = query;
//     if (query.isEmpty) {
//       filteredItems = List.from(previousDisplayedItems);
//       isSearchActive = false;
//       startHintRotation();
//     } else {
//       if (!isSearchActive) {
//         previousDisplayedItems = List.from(filteredItems);
//         isSearchActive = true;
//         stopHintRotation();
//       }
//       filteredItems = allItems
//           .where((item) => item['itname']
//               .toString()
//               .toLowerCase()
//               .contains(query.toLowerCase()))
//           .toList();
//     }
//     notifyListeners();
//   }

//   void selectCategory(int id, int shopid) {
//     selectedCategoryId = id;
//     _fetchCategories(id, shopid);
//   }

//   void selectSubCategory(int id, int shopid) {
//     selectedSubCategoryId = id;
//     _fetchDishes(id, shopid);
//   }

//   String get waiterName =>
//       responseData.isNotEmpty ? responseData[0]['wname'] : "Waiter";
// }

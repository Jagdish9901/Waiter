import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:shimmer/shimmer.dart';
import 'package:waiter_app/OrderHistoryScreen.dart';
import 'package:waiter_app/TableTransfer.dart';
import 'package:waiter_app/cartprovider.dart';
import 'package:waiter_app/login.dart';
import 'package:waiter_app/utils/apphelper.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> responseData;

  const HomeScreen({Key? key, required this.responseData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<Map<String, dynamic>> allItems = []; // Store all menu items
  // List<Map<String, dynamic>> filteredItems = []; // Initially empty

  int gstType = 0;
  String? selectedTable;
  List<dynamic> tableData = [];
  bool isLoading = false;
  List<dynamic> itemData = [];
  bool isItemLoading = false;
  List<dynamic> categories = [];
  bool isCategoryLoading = false;
  Map<int, int> itemCounts = {};
  TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _showLogoutButton = false;
  int? shopid;
  int? selectedCategoryId; // Default to first category
  int? selectedSubCategoryId;
  List<dynamic> categories1 = [];

  // Variables for dish types
  List<dynamic> dishTypes = [];

  bool isDishTypeLoading = false;

  Color deliveryButtonColor = Colors.black;
  Color takeawayButtonColor = Colors.black;
  int? selectedDishTypeId;

  @override
  void initState() {
    super.initState();
    int shopId =
        widget.responseData[0]['shopid'] ?? 0; // Ensure shopid is not null

    setState(() {
      Apphelper.shopid = shopId;
    });
    shopmasgsttype();
    _fetchTableData(shopId);
    _fetchItemData(shopId);
    _fetchDishTypes(shopId); // Fetch dish types
  }

  // Save login state in SharedPreferences
  Future<void> _saveLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("waiterName", widget.responseData[0]['wname']);
  }

  // Fetch table data
  Future<void> _fetchTableData(int shopid) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/table'));
      if (response.statusCode == 200) {
        setState(() {
          // print("_fetchTableData ${response.body}");
          tableData = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load tables")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching tables")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchItemData(int shopid) async {
    setState(() {
      isItemLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://hotelserver.billhost.co.in/$shopid/item'));

      if (response.statusCode == 200) {
        setState(() {
          allItems = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)); // Store all items
          filteredItems = []; // Keep filteredItems empty initially
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load items")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching items")),
      );
    } finally {
      setState(() {
        isItemLoading = false;
      });
    }
  }

  Future<void> _fetchDishTypes(int? shopid) async {
    final response = await http
        .get(Uri.parse("https://hotelserver.billhost.co.in/$shopid/Dishtype"));

    if (response.statusCode == 200) {
      List<dynamic> fetchedDishTypes = json.decode(response.body);
      setState(() {
        dishTypes = fetchedDishTypes;

        if (dishTypes.isNotEmpty) {
          selectedCategoryId = dishTypes[0]['id'];
          _fetchCategories(selectedCategoryId ?? 0, shopid ?? 0);
        }
      });
    }
  }

  Future shopmasgsttype() async {
    try {
      final gstResponse = await http.get(Uri.parse(
          'https://hotelserver.billhost.co.in/shopmas/${Apphelper.shopid}'));

      if (gstResponse.statusCode == 200) {
        final gstData = jsonDecode(gstResponse.body);
        // print(gstData['gsttype']);

        Apphelper.gsttype = (gstData['gsttype'] == 0) ? false : true;
        setState(() {});
        // print('https://hotelserver.billhost.co.in/shopmas/${Apphelper.shopid}');
        // print(Apphelper.gsttype);
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _fetchDishes(int dishTypeId, int shopid) async {
    setState(() {
      isItemLoading = true; // Show loading indicator
    });

    try {
      final url =
          'https://hotelserver.billhost.co.in/ItemSearchBydtcode/$shopid/$dishTypeId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> dishes = jsonDecode(response.body);

        setState(() {
          // Explicitly cast List<dynamic> to List<Map<String, dynamic>>
          filteredItems = List<Map<String, dynamic>>.from(dishes);
          isItemLoading = false;
        });
      } else {
        developer.log(
            'Failed to load dishes. Status Code: ${response.statusCode}',
            name: 'API Error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load dishes")),
        );
        setState(() {
          filteredItems = [];
          isItemLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching dishes: $e',
          name: 'API Exception', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching dishes")),
      );
      setState(() {
        filteredItems = [];
        isItemLoading = false;
      });
    }
  }

//1/1 api

  Future<void> _fetchCategories(int? dtId, int? shopid) async {
    setState(() {
      isCategoryLoading = true;
    });

    final response = await http.get(Uri.parse(
        "https://hotelserver.billhost.co.in/finddishtype/${shopid ?? 0}/${dtId ?? 0}"));

    if (response.statusCode == 200) {
      List<dynamic> fetchedCategories = json.decode(response.body);
      setState(() {
        categories = fetchedCategories;
        isCategoryLoading = false;

        if (categories.isNotEmpty) {
          selectedSubCategoryId = categories[0]['id'];
          _fetchDishes(selectedSubCategoryId ?? 0, shopid ?? 0);
        }
      });
    } else {
      setState(() {
        isCategoryLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> allItems = []; // Store all menu items
  List<Map<String, dynamic>> filteredItems = []; // Initially empty
  List<Map<String, dynamic>> previousDisplayedItems =
      []; // Backup of items when search starts
  bool isSearchActive = false; // Track if search is active

  void searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        // Restore the items that were displayed before searching
        filteredItems = List.from(previousDisplayedItems);
        isSearchActive = false; // Reset search flag
      } else {
        if (!isSearchActive) {
          // Store the currently visible items before search starts
          previousDisplayedItems = List.from(filteredItems);
          isSearchActive = true; // Mark that search has started
        }
        // Apply filtering
        filteredItems = allItems
            .where((item) => item['itname']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String waiterName = widget.responseData.isNotEmpty
        ? widget.responseData[0]['wname']
        : "Waiter";
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFB300), // Darkest yellow at the top
                // Color(0xFFFFFFFF),
                // Color(0xFFFFFFFF),
                Color(0xFFFFC107),
                Color(0xFFFFE082), // Lightest at the bottom
              ],
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 3.5.h),

            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Popup Menu moved before the "Select Table" button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          _logout(context);
                        } else if (value == 'about') {
                          _showAboutDialog();
                        } else if (value == 'help') {
                          _showHelpDialog();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'about',
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  'About',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'help',
                            child: Row(
                              children: [
                                Icon(Icons.help, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  'Help',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            enabled:
                                true, // Disabled to show waiter name as info
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  waiterName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Order History',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderHistoryScreen()));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.history, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  'Order History',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: "Table Transfer",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TableTransfer()));
                              // table transfer screen name
                            },
                            child: Row(
                              children: [
                                Icon(Icons.swap_horiz, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  "Table Transfer",
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.black),
                                )
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text('Logout',
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Colors.black)),
                              ],
                            ),
                          ),
                        ];
                      },
                      child: Icon(Icons.menu, size: 23.sp, color: Colors.black),
                    ),
                  ),
                  SizedBox(
                      width: 0.5.w), // Added space between menu and buttons
                  Expanded(
                    flex: 2,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                int shopid =
                                    widget.responseData[0]['shopid'] ?? 0;
                                _showTableSelectionDialog(context, shopid);
                                cartProvider.setSelectedOption("Table");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    cartProvider.selectedOption == "Table"
                                        ? Colors.green
                                        : Colors.black,
                                foregroundColor: Colors.white,
                                minimumSize: Size(18.w, 6.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                              ),
                              child: Text(
                                cartProvider.selectedTableName.isNotEmpty
                                    ? cartProvider.selectedTableName
                                    : "Select Table",
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ),

                            SizedBox(width: 0.3.w),
                            ElevatedButton(
                              onPressed: () {
                                cartProvider.setSelectedOption("Delivery");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    cartProvider.selectedOption == "Delivery"
                                        ? Colors.green
                                        : Colors.black,
                                foregroundColor: Colors.white,
                                minimumSize: Size(18.w, 6.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                              ),
                              child: Text("Delivery",
                                  style: TextStyle(fontSize: 15.sp)),
                            ),
                            SizedBox(width: 0.3.w),
                            ElevatedButton(
                              onPressed: () {
                                cartProvider.setSelectedOption("Takeaway");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    cartProvider.selectedOption == "Takeaway"
                                        ? Colors.green
                                        : Colors.black,
                                foregroundColor: Colors.white,
                                minimumSize: Size(18.w, 6.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                              ),
                              child: Text("Takeaway",
                                  style: TextStyle(fontSize: 15.sp)),
                            ),
                            SizedBox(width: 0.5.w),

                            // Notification Icon Button
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.notifications,
                                      color: Colors.black, size: 22.sp),
                                  onPressed: () {
                                    _showNotifications(
                                        context); // Function to open notifications
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.all(0.8.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search menu items...",
                  filled: true,
                  // Enables the background color
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.5.w),
                ),
                onChanged: (query) => searchItems(query),
              ),
            ),

            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 1.5.w, bottom: 1.h),
              child: Text(
                "Categories",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // Display Dish Types below search bar
            isDishTypeLoading
                ? Center(child: SizedBox())
                : Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Container(
                      // color: Colors.red,
                      height: 15.5.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: dishTypes.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              selectedCategoryId == dishTypes[index]['id'];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.3.w),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = dishTypes[index]
                                      ['id']; // Update selected category
                                });
                                _fetchCategories(dishTypes[index]['id'],
                                    widget.responseData[0]['shopid']);
                              },
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    radius: 9.w,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                          dishTypes[index]['imagename'] != null
                                              ? "https://app.billhost.co.in/dishtype/${dishTypes[index]['imagename']}"
                                              : "https://via.placeholder.com/150", // Fallback image if null
                                        )),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.transparent,
                                          // Change border color when selected
                                          width: 0.5.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  SizedBox(
                                    width: 16.w,
                                    child: Text(
                                      dishTypes[index]['dtname'].toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.black,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

            Padding(
              padding: EdgeInsets.only(left: 1.5.w, bottom: 0.5.h),
              child: Text(
                "Sub Categories",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // side scroll code,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60.h,
                    width: 18.w,
                    child: ListView.builder(
                      itemCount: categories.length,
                      padding: EdgeInsets.only(left: 0.9.w),
                      itemBuilder: (context, index) {
                        bool isSelected =
                            selectedSubCategoryId == categories[index]['id'];
                        int id = categories[index]['id'];
                        return InkWell(
                          onTap: () {
                            int shopidd = widget.responseData[0]['shopid'];
                            _fetchDishes(id, shopidd);
                            setState(() {
                              selectedSubCategoryId = categories[index]
                                  ['id']; // Update selected subcategory
                              // filteredItems = List.from(allItems);
                            });
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                radius: 9.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                      categories[index]['imagename'] != null
                                          ? "https://app.billhost.co.in/dishhead/${categories[index]['imagename']}"
                                          : "https://via.placeholder.com/150", // Fallback image if null
                                    )),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                      // Highlight selected category
                                      width: 0.5.w,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.1.h),
                              Text(
                                categories[index]['dhname'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Display Menu Items

                  Expanded(
                    child: isItemLoading
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              );
                            },
                          )
                        : filteredItems.isEmpty
                            ? const Center(
                                child: Text("No items available",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)))
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio:
                                        0.9, // Adjusted for better layout
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: filteredItems.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    // print(item.toString());
                                    int itemCount = itemCounts[item['id']] ?? 0;

                                    // // Update restrate dynamically based on gsttype
                                    // double restrate = item['restrate']
                                    //     .toDouble(); // Convert to double
                                    // // int gstType = shopDetails['gsttype']; // Fetch gsttype from API response

                                    // if (gstType == 1) {
                                    //   double gst = item['gst'].toDouble();
                                    //   double cess = item['cess'].toDouble();
                                    //   restrate = restrate +
                                    //       ((cess + gst) / (100 + cess + gst)) *
                                    //           restrate;
                                    // }

                                    return Container(
                                      // padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF59D),
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // Image inside an inner container
                                          Container(
                                            height: 10.4
                                                .h, // Adjust image container height
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(15),
                                              ),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  item['imagename'] != null
                                                      ? "https://app.billhost.co.in/item/${item['imagename']}"
                                                      : "https://via.placeholder.com/150",
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h), // Spacing

                                          // Item Name
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4, // 40% of screen width
                                            height: 3.2.h,
                                            child: Text(
                                              item['itname'].toString(),
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines:
                                                  2, // Ensures text wraps into two lines
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                          ),

                                          SizedBox(height: 0.3.h), // Spacing

                                          // Row for increment, decrement, and price
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: 1.w,
                                              right: 1.w,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Consumer<CartProvider>(
                                                  builder: (context,
                                                      cartProvider, child) {
                                                    int itemCount =
                                                        cartProvider.itemCounts[
                                                                item['id']] ??
                                                            0;

                                                    return AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      width: itemCount == 0
                                                          ? 12.w
                                                          : 18.w,
                                                      height: 4.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                      ),
                                                      child: itemCount == 0
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                cartProvider
                                                                    .addToCart(
                                                                        item);
                                                              },
                                                              child: Center(
                                                                child: Text(
                                                                  "ADD",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .removeFromCart(
                                                                            item);
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 15.sp,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  itemCount
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .addToCart(
                                                                            item);
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    size: 15.sp,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                    );
                                                  },
                                                ),
                                                // Text(item.toString()),
                                                Text(
                                                  "₹${item['restrate'].toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontSize: 15.sp),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                  )

// SizedBox(height: 10),
                ],
              ),
            ),
          ])),
    );
  }

  void _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear stored data
      await prefs.clear();
      print(
          "SharedPreferences cleared: ${prefs.getString('someKey')}"); // Debug

      // Reset cart provider
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart(); // Clears cart items and quantities
      print("Cart cleared"); //debug

      if (!context.mounted) {
        print("Context not mounted"); // Debug
        return;
      }
      print("Context mounted: ${context.mounted}"); //debug
      try {
        Apphelper.connectedDevice!.disconnect();
      } catch (e) {
        print("Apphelper error : $e");
      }

      // Navigate to login screen and replace the current screen
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);

      print("Logout successful"); // Debugging confirmation
    } catch (e) {
      print("Logout error: $e"); // Debugging any errors
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("About"),
          content: const Text("This is a waiter app"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Help"),
          content: const Text("Your help information goes here."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

// show notification function

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notifications"),
          content: Text(
              "No new notifications."), // You can replace this with dynamic content
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showTableSelectionDialog(BuildContext context, int shopid) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    Timer? tableUpdateTimer; // Declare Timer

    // Function to update table data every 6 seconds
    void startTableUpdateTimer(StateSetter setStateDialog, int shopid) {
      tableUpdateTimer?.cancel(); // Cancel previous timer (if any)

      tableUpdateTimer =
          Timer.periodic(const Duration(seconds: 6), (timer) async {
        await _fetchTableData(shopid); // Fetch tables for the selected shop
        setStateDialog(() {}); // Update UI inside the dialog
      });
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          if (tableUpdateTimer == null) {
            startTableUpdateTimer(
                setStateDialog, shopid); // Start with correct shopid
          }

          return AlertDialog(
            title: const Text("Select a Table"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5,
              child: isLoading
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: tableData.length,
                      itemBuilder: (context, index) {
                        String tableName = tableData[index]['tname'].toString();
                        int tableId = tableData[index]['id'];
                        int status = tableData[index]['status'];

                        Color tableColor;
                        Color textColor;

                        if (status == 0) {
                          tableColor = Colors.white;
                          textColor = Colors.black;
                        } else if (status == 1) {
                          tableColor = Colors.green;
                          textColor = Colors.white;
                        } else {
                          tableColor = Colors.red;
                          textColor = Colors.white;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (status == 2) {
                              _showPaymentPendingDialog(context);
                            } else {
                              cartProvider.setSelectedTable(tableId, tableName);
                              tableUpdateTimer
                                  ?.cancel(); // Stop timer on selection
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: tableColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tableName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    ).then((_) {
      tableUpdateTimer?.cancel(); // Stop the timer when the dialog is closed
    });
  }

  void _showPaymentPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Table Not Available"),
        content: const Text("Payment is pending for this table....."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

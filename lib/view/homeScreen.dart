import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waiter_app/NotificationScreen.dart';
import 'package:waiter_app/OrderHistoryScreen.dart';
import 'package:waiter_app/TableTransfer.dart';
import 'package:waiter_app/models/home_viewmodel.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/providers/notification_provider.dart';
import 'package:waiter_app/utils/auth_utils.dart';

class HomeScreen extends StatelessWidget {
  final List<dynamic> responseData;

  const HomeScreen({Key? key, required this.responseData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(responseData: responseData),
      child: Scaffold(
        body: _HomeScreenContent(responseData: responseData),
      ),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  final List<dynamic> responseData;
  final TextEditingController _searchController = TextEditingController();

  _HomeScreenContent({Key? key, required this.responseData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFB300),
            Color(0xFFFFC107),
            Color(0xFFFFE082),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3.5.h),
          _buildAppBar(context, viewModel, cartProvider, notificationProvider),
          SizedBox(height: 1.h),
          _buildSearchField(context, viewModel),
          SizedBox(height: 1.h),
          _buildCategoriesHeader(context),
          _buildDishTypes(context, viewModel),
          _buildSubCategoriesHeader(context),
          _buildMainContent(context, viewModel, cartProvider),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, HomeViewModel viewModel,
      CartProvider cartProvider, NotificationProvider notificationProvider) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (BuildContext context) =>
                _buildMenuItems(context, viewModel),
            child: Icon(Icons.menu, size: 23.sp, color: Colors.black),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTableButton(context, cartProvider),
                // SizedBox(width: 0.5.w),
                // _buildDeliveryButton(context, cartProvider),
                // SizedBox(width: 3.w),
                // _buildTakeawayButton(context, cartProvider),
                SizedBox(width: 20.w),
                _buildNotificationIcon(context, notificationProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      BuildContext context, HomeViewModel viewModel) {
    return [
      PopupMenuItem<String>(
        value: 'about',
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.black),
            SizedBox(width: 2.w),
            Text('About', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'help',
        child: Row(
          children: [
            Icon(Icons.help, color: Colors.black),
            SizedBox(width: 2.w),
            Text('Help', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.black),
            SizedBox(width: 2.w),
            Text(viewModel.waiterName, style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'Order History',
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.black),
            SizedBox(width: 2.w),
            Text('Order History', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: "Table Transfer",
        child: Row(
          children: [
            Icon(Icons.swap_horiz, color: Colors.black),
            SizedBox(width: 2.w),
            Text("Table Transfer", style: TextStyle(fontSize: 16.sp))
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.black),
            SizedBox(width: 2.w),
            Text('Logout', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
    ];
  }

  Widget _buildTableButton(BuildContext context, CartProvider cartProvider) {
    return ElevatedButton(
      onPressed: () {
        int shopid = responseData[0]['shopid'] ?? 0;
        _showTableSelectionDialog(context, shopid);
        cartProvider.setSelectedOption("Table");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: cartProvider.selectedOption == "Table"
            ? Colors.green
            : Colors.black,
        foregroundColor: Colors.white,
        minimumSize: Size(30.w, 6.h),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      ),
      child: Text(
        cartProvider.selectedTableName.isNotEmpty
            ? cartProvider.selectedTableName
            : "Select Table",
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  // Widget _buildDeliveryButton(BuildContext context, CartProvider cartProvider) {
  //   return ElevatedButton(
  //     onPressed: () => cartProvider.setSelectedOption("Delivery"),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: cartProvider.selectedOption == "Delivery"
  //           ? Colors.green
  //           : Colors.black,
  //       foregroundColor: Colors.white,
  //       minimumSize: Size(18.w, 6.h),
  //       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
  //     ),
  //     child: Text("Delivery", style: TextStyle(fontSize: 15.sp)),
  //   );
  // }

  // Widget _buildTakeawayButton(BuildContext context, CartProvider cartProvider) {
  //   return ElevatedButton(
  //     onPressed: () => cartProvider.setSelectedOption("Takeaway"),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: cartProvider.selectedOption == "Takeaway"
  //           ? Colors.green
  //           : Colors.black,
  //       foregroundColor: Colors.white,
  //       minimumSize: Size(18.w, 6.h),
  //       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
  //     ),
  //     child: Text("Takeaway", style: TextStyle(fontSize: 15.sp)),
  //   );
  // }

  Widget _buildNotificationIcon(
      BuildContext context, NotificationProvider notificationProvider) {
    int unreadCount = notificationProvider.unreadCount;
    final badgeText = unreadCount > 9 ? '9+' : '$unreadCount';
    final badgeWidth = unreadCount > 9 ? 5.w : 4.w;
    final fontSize = unreadCount > 9 ? 12.4.sp : 14.sp;

    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black, size: 22.sp),
          onPressed: () => _showNotifications(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 9,
            top: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              width: badgeWidth,
              height: 2.3.h,
              child: Center(
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(0.8.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search menu items...",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.5.w),
        ),
        onChanged: (query) => viewModel.searchItems(query),
      ),
    );
  }

  Widget _buildCategoriesHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1.5.w, bottom: 0.8.h),
      child: Text(
        "Categories",
        style: TextStyle(
            color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDishTypes(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isDishTypeLoading) {
      return Center(child: SizedBox());
    }

    return Padding(
      padding: EdgeInsets.only(left: 1.w),
      child: Container(
        height: 15.h,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.dishTypes.length,
          itemBuilder: (context, index) {
            bool isSelected = viewModel.selectedCategoryId ==
                viewModel.dishTypes[index]['id'];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.3.w),
              child: InkWell(
                onTap: () {
                  viewModel.selectCategory(viewModel.dishTypes[index]['id'],
                      responseData[0]['shopid']);
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      radius: 9.w,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(viewModel.dishTypes[index]
                                        ['imagename'] !=
                                    null
                                ? "https://app.billhost.co.in/dishtype/${viewModel.dishTypes[index]['imagename']}"
                                : "https://via.placeholder.com/150"),
                          ),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 0.5.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SizedBox(
                      width: 16.w,
                      child: Text(
                        viewModel.dishTypes[index]['dtname'].toString(),
                        style: TextStyle(
                            color: isSelected ? Colors.black : Colors.black,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildSubCategoriesHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1.5.w, bottom: 0.5.h),
      child: Text(
        "Sub Categories",
        style: TextStyle(
            color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, HomeViewModel viewModel,
      CartProvider cartProvider) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubCategoriesList(context, viewModel),
          _buildItemsGrid(context, viewModel, cartProvider),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesList(
      BuildContext context, HomeViewModel viewModel) {
    return SizedBox(
      height: 60.h,
      width: 18.w,
      child: ListView.builder(
        itemCount: viewModel.categories.length,
        padding: EdgeInsets.only(left: 0.9.w),
        itemBuilder: (context, index) {
          bool isSelected = viewModel.selectedSubCategoryId ==
              viewModel.categories[index]['id'];
          int id = viewModel.categories[index]['id'];
          return InkWell(
            onTap: () {
              int shopid = responseData[0]['shopid'];
              viewModel.selectSubCategory(id, shopid);
            },
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  radius: 9.w,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(viewModel.categories[index]
                                    ['imagename'] !=
                                null
                            ? "https://app.billhost.co.in/dishhead/${viewModel.categories[index]['imagename']}"
                            : "https://via.placeholder.com/150"),
                      ),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 0.5.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0.1.h),
                Text(
                  viewModel.categories[index]['dhname'],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, HomeViewModel viewModel,
      CartProvider cartProvider) {
    return Expanded(
      child: viewModel.isItemLoading
          ? _buildShimmerLoader(context)
          : viewModel.filteredItems.isEmpty
              ? Center(
                  child: Text("No items available",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)))
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: viewModel.filteredItems.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final item = viewModel.filteredItems[index];
                      return _buildItemCard(context, item, cartProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmerLoader(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item,
      CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFF59D),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image(
                    image: NetworkImage(
                      item['imagename'] != null
                          ? "https://app.billhost.co.in/item/${item['imagename']}"
                          : "https://via.placeholder.com/150",
                    ),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      // return Image(
                      //   image: NetworkImage(
                      //       "https://media.istockphoto.com/id/517377174/photo/artificial-plastic-food-examining-todays-food-industry.jpg?s=612x612&w=0&k=20&c=uSXrEC1VGzqMmQ4hRIvPIjlh6Igq8Pj4z1H-OM5v4t8="),
                      //   fit: BoxFit.cover,
                      // );
                      return Icon(
                        Icons.broken_image,
                        size: 38.sp,
                      );
                    }),
              ),
            ),
          ),
          // Container(
          //   height: 10.4.h,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          //     image: DecorationImage(
          //       image: NetworkImage(item['imagename'] != null
          //           ? "https://app.billhost.co.in/item/${item['imagename']}"
          //           : "https://via.placeholder.com/150"),
          //       fit: BoxFit.fill,
          //     ),
          //   ),
          // ),
          SizedBox(height: 0.8.h),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 3.h,
            child: Text(
              item['itname'].toString(),
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
          SizedBox(height: 1.2.h),
          Container(
            padding: EdgeInsets.only(left: 1.w, right: 1.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildItemCounter(context, item, cartProvider),
                Text("₹${item['restrate'].toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 15.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCounter(BuildContext context, Map<String, dynamic> item,
      CartProvider cartProvider) {
    int itemCount = cartProvider.itemCounts[item['id']] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: itemCount == 0 ? 12.w : 18.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: itemCount == 0
          ? GestureDetector(
              onTap: () => cartProvider.addToCart(item),
              child: Center(
                child: Text(
                  "ADD",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => cartProvider.removeFromCart(item),
                  child: Icon(Icons.remove, size: 15.sp, color: Colors.white),
                ),
                Text(
                  itemCount.toString(),
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => cartProvider.addToCart(item),
                  child: Icon(Icons.add, size: 15.sp, color: Colors.white),
                ),
              ],
            ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'logout') {
      AuthUtils.logout(context);
    } else if (value == 'about') {
      _showAboutDialog(context);
    } else if (value == 'help') {
      _showHelpDialog(context);
    } else if (value == 'Order History') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => OrderHistoryScreen()));
    } else if (value == "Table Transfer") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TableTransfer()));
    }
  }

  void _showAboutDialog(BuildContext context) {
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

  void _showHelpDialog(BuildContext context) {
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

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  void _showTableSelectionDialog(BuildContext context, int shopid) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    Timer? tableUpdateTimer;

    void startTableUpdateTimer(StateSetter setStateDialog, int shopid) {
      tableUpdateTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        await viewModel.fetchTableData(shopid);
        setStateDialog(() {});
      });
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          if (tableUpdateTimer == null) {
            startTableUpdateTimer(setStateDialog, shopid);
          }
          return AlertDialog(
            title: const Text("Select a Table"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5,
              child: viewModel.isLoading
                  ? _buildTableShimmerLoader(context)
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: viewModel.tableData.length,
                      itemBuilder: (context, index) {
                        String tableName =
                            viewModel.tableData[index]['tname'].toString();
                        int tableId = viewModel.tableData[index]['id'];
                        int status = viewModel.tableData[index]['status'];
                        Color tableColor = status == 0
                            ? Colors.white
                            : status == 1
                                ? Colors.green
                                : Colors.red;
                        Color textColor =
                            status == 0 ? Colors.black : Colors.white;

                        return GestureDetector(
                          onTap: () {
                            if (status == 2) {
                              _showPaymentPendingDialog(context);
                            } else {
                              cartProvider.setSelectedTable(tableId, tableName);
                              tableUpdateTimer?.cancel();
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
    ).then((_) => tableUpdateTimer?.cancel());
  }

  Widget _buildTableShimmerLoader(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }

  void _showPaymentPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Table is not available"),
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

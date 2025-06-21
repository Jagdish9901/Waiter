import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:waiter_app/models/cart_viewmodel.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/utils/apphelper.dart';
import 'package:waiter_app/utils/appstring.dart';
import 'package:waiter_app/utils/dialog_helper.dart';

class CartScreen extends StatefulWidget {
  final List<dynamic> responseData;
  final Map<int, int> itemCounts;
  final List<Map<String, dynamic>> menuItems;
  final String? selectedOption;

  const CartScreen({
    Key? key,
    required this.responseData,
    required this.itemCounts,
    required this.menuItems,
    required this.selectedOption,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = CartViewModel(
      context: context,
      responseData: widget.responseData,
      itemCounts: widget.itemCounts,
      menuItems: widget.menuItems,
      selectedOption: widget.selectedOption,
    );

    final cartProvider = Provider.of<CartProvider>(context);
    final selectedItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
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
        child: Padding(
          padding: EdgeInsets.only(
            top: 5.0,
            left: 10.0,
            right: 10.0,
            bottom: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Selected Order Type
              Text(
                "Order type : ${cartProvider.selectedOption ?? "None"}",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              if (cartProvider.selectedOption == "Table")
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    "Table No. : ${cartProvider.selectedTableName ?? "None"}",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 1.h),

              if (Apphelper.printerType == Appstring.bluetoothPrinter)
                if (Apphelper.connectedDevice != null)
                  Text(Apphelper.connectedDevice!.platformName.toString()),

              // Display Cart Items
              Expanded(
                child: selectedItems.isEmpty
                    ? const Center(
                        child: Text(
                          "No items in cart",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          final quantity =
                              cartProvider.itemCounts[item['id']] ?? 0;
                          return GestureDetector(
                              onTap: () async {
                                bool packConfirmed =
                                    await showConfirmationDialog(context,
                                        "Do you want to pack this item ?");
                                cartProvider.setItemComment(item['id'],
                                    packConfirmed ? "(Pack this item )" : "");
                              },
                              child: Card(
                                elevation: 3,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Text(
                                              item['itname'].toString(),
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                          ),
                                          Text(
                                            "Price: ₹${(Apphelper().totalgst(item['restrate'], item['cess'], item['gst'], Apphelper.gsttype!, quantity).toStringAsFixed(2))}",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => cartProvider
                                                .removeFromCart(item),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(30, 30),
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Icon(Icons.remove,
                                                color: Colors.white,
                                                size: 16.sp),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: Text(
                                              quantity.toString(),
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                cartProvider.addToCart(item),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(30, 30),
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Icon(Icons.add,
                                                color: Colors.white,
                                                size: 16.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            if (cartProvider.selectedOption == null ||
                                cartProvider.selectedOption == "None") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please select order type"),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _viewModel.postCartData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text("Proceed to Order"),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            if (cartProvider.selectedOption == null ||
                                cartProvider.selectedOption == "None") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select order type"),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _viewModel.postCartDataPrintAndOrder();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text("Order and Print"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TableTransfer extends StatefulWidget {
  @override
  State<TableTransfer> createState() => _TableTransferState();
}

class _TableTransferState extends State<TableTransfer> {
  List<String> fromTables = [];
  List<String> toTables = [];

  String? selectedFromTable;
  String? selectedToTable;

  @override
  void initState() {
    super.initState();
    fetchFromTables();
    fetchToTables();
  }

  Future<void> fetchFromTables() async {
    final prefs = await SharedPreferences.getInstance();
    final int? shopid = prefs.getInt("wcode");
    final url = 'https://hotelserver.billhost.co.in/$shopid/table/1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          fromTables =
              data.map<String>((item) => item['tname'].toString()).toList();
        });
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      print('Error fetching from tables: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching From Table list')),
      );
    }
  }

  Future<void> fetchToTables() async {
    final prefs = await SharedPreferences.getInstance();
    final int? shopid = prefs.getInt("wcode");
    final url = 'https://hotelserver.billhost.co.in/$shopid/table/0';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          toTables =
              data.map<String>((item) => item['tname'].toString()).toList();
        });
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      print('Error fetching to tables: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching To Table list')),
      );
    }
  }

  void transferTable() {
    if (selectedFromTable != null &&
        selectedToTable != null &&
        selectedFromTable != selectedToTable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Transferred from $selectedFromTable to $selectedToTable')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select valid tables')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Table Transfer'),
            backgroundColor: Color(0XFFFFB300),
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
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FROM TABLE
                  Text(
                    "From Table:",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),

                  DropdownButtonFormField2(
                    value: selectedFromTable,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    hint: Text('Select...'),
                    items: fromTables.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFromTable = value;
                      });
                    },
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 30.h,
                      width: 92.2.w, // Or set a min width if preferred
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      elevation: 2,
                      offset: const Offset(0, 5),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      iconSize: 24,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Center(
                    child: Icon(
                      Icons.swap_vert,
                      size: 25.sp,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // TO TABLE
                  Text(
                    "To Table:",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),

                  DropdownButtonFormField2(
                    value: selectedToTable,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    hint: Text('Select...'),
                    items: toTables.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedToTable = value;
                      });
                    },
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 30.h,
                      width: 92.2.w, // Set a fixed or minimum width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      elevation: 2,
                      offset: const Offset(0, 5), // Dropdown appears just below
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      iconSize: 24,
                    ),
                  ),

                  SizedBox(height: 17.h),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        // foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: transferTable,
                      child: Text(
                        'Transfer Table',
                        style: TextStyle(fontSize: 18.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

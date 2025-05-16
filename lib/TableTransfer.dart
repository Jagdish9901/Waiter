import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:waiter_app/api_services/api_service.dart';

class TableTransfer extends StatefulWidget {
  @override
  _TableTransferState createState() => _TableTransferState();
}

class _TableTransferState extends State<TableTransfer> {
  List<Map<String, dynamic>> fromTables = [];
  List<Map<String, dynamic>> toTables = [];

  Map<String, dynamic>? selectedFromTable;
  Map<String, dynamic>? selectedToTable;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      final occupiedTables = await _apiService.fetchOccupiedTables();
      final availableTables = await _apiService.fetchAvailableTables();
      setState(() {
        fromTables = occupiedTables;
        toTables = availableTables;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tables: ${e.toString()}')),
      );
    }
  }

  Future<void> _transferTable() async {
    if (selectedFromTable == null || selectedToTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both tables')),
      );
      return;
    }

    if (selectedFromTable!['id'] == selectedToTable!['id']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot transfer to the same table')),
      );
      return;
    }

    try {
      await _apiService.transferTable(
        fromId: selectedFromTable!['id'].toString(),
        toId: selectedToTable!['id'].toString(),
        toName: selectedToTable!['tname'].toString(),
        nop: selectedFromTable!['nop'].toString(),
        wcode: selectedFromTable!['wcode'].toString(),
        wname: selectedFromTable!['wname'].toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table transferred successfully')),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to transfer table: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Table Transfer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  // From Table Section
                  Text(
                    "From Table:",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),
                  _buildTableDropdown(
                    value: selectedFromTable,
                    items: fromTables,
                    onChanged: (value) =>
                        setState(() => selectedFromTable = value),
                  ),

                  SizedBox(height: 3.h),
                  Center(child: Icon(Icons.swap_vert, size: 25.sp)),
                  SizedBox(height: 3.h),

                  // To Table Section
                  Text(
                    "To Table:",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),
                  _buildTableDropdown(
                    value: selectedToTable,
                    items: toTables,
                    onChanged: (value) =>
                        setState(() => selectedToTable = value),
                  ),

                  Spacer(),

                  // Transfer Button
                  SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _transferTable,
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

  Widget _buildTableDropdown({
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required Function(Map<String, dynamic>?) onChanged,
  }) {
    return DropdownButtonFormField2<Map<String, dynamic>>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item['tname']),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownStyleData: DropdownStyleData(
        maxHeight: 30.h,
        width: 92.2.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.black),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        iconSize: 24,
      ),
    );
  }
}

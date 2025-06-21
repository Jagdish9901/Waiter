import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
    BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFFFFE082),
          title: Text("Packing Confirmation ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            message,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, false),
              child: Text("No"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        ),
      ) ??
      false; // return false if dialog is dismissed
}

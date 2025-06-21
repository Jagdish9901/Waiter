import 'package:flutter/material.dart';

Future<void> showCustomErrorDialog({
  required BuildContext context,
  required String message,
  String title = "Error",
  Color backgroundColor = const Color(0xFFFFF3CD), // light yellow
  Color titleColor = Colors.black,
  Color messageColor = Colors.black87,
  Color buttonColor = Colors.black,
  Color buttonTextColor = Colors.white,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
      ),
      content: Text(
        message,
        style: TextStyle(color: messageColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

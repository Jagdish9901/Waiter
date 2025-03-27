import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ApiConstants {
  static const String baseUrl = "https://hotelserver.billhost.co.in";
}

class ApiService {
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    String encodedUsername = Uri.encodeComponent(username);
    String encodedPassword = Uri.encodeComponent(password);
    String apiUrl =
        "${ApiConstants.baseUrl}/checkWaiter/$encodedUsername/$encodedPassword";

    try {
      var response = await http.get(Uri.parse(apiUrl));

      developer.log("Response Status Code: ${response.statusCode}");
      developer.log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          return responseData[0]; // Returning first object from the list
        } else {
          return null; // No user found
        }
      } else {
        return null;
      }
    } catch (e) {
      developer.log("Error: $e");
      return null;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class UrlHandler
{
   static String _baseUrl="";
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  static Future<Map<String, dynamic>> get(String endpoint, dynamic data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.get(
      url,
    );
    return _handleResponse(response);
  }
  static Future<Map<String, dynamic>> delete(String endpoint, dynamic data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.delete(
      url,
    );
    return _handleResponse(response);
  }
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      // Parse the response body (assuming JSON format)
      final data = json.decode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

}
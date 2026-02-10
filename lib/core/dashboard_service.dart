import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';
import 'auth_service.dart'; // To get the base URL if needed, or define it here

class DashboardService {
  // Using the same IP as AuthService.
  // Ideally, this should be in a shared config file.
  static const String _baseUrl = 'http://10.236.160.97:8000/api/v1';

  Future<DashboardData?> getDashboardData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return DashboardData.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

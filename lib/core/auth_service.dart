import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../models/user_model.dart';

class AuthService {
  // Use localhost for web, and 10.0.2.2 for Android emulator to access localhost
  // Allowing the URL to be configured or using a smarter default would be better in production
  static const String _baseUrl = 'http://10.236.160.97:8000/api/v1';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final deviceName = await _getDeviceName();

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final userData = data['data']['user'];
        final token = data['data']['token'];
        final user = UserModel.fromJson(userData, token);
        return {'success': true, 'user': user, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown Device';

    try {
      if (kIsWeb) {
        final webBrowserInfo = await deviceInfo.webBrowserInfo;
        deviceName = webBrowserInfo.userAgent ?? 'Web Browser';
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceName = iosInfo.utsname.machine;
        } else if (Platform.isLinux) {
          final linuxInfo = await deviceInfo.linuxInfo;
          deviceName = linuxInfo.prettyName;
        } else if (Platform.isMacOS) {
          final macOsInfo = await deviceInfo.macOsInfo;
          deviceName = macOsInfo.computerName;
        } else if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          deviceName = windowsInfo.computerName;
        }
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    return deviceName;
  }
}

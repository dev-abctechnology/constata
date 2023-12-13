import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRefreshController {
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };
  static const Map<String, String> authHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': 'Basic amFydmlzQGVmY3MyMDE4OlM0SkJ4NzRv',
  };

  int retryCount = 0;
  static const int maxRetries = 3;

  Future<String> checkAuth(String token) async {
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        ...jsonHeaders,
      };

      final request = http.Request('GET', Uri.parse(apiUrl));
      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode != 401) {
        return '';
      }

      return await refreshAuthToken(token);
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<String> refreshAuthToken(String token) async {
    if (retryCount >= maxRetries) {
      return '';
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    final body = jsonDecode(sharedPreferences.getString("authentication")!);

    final refresh = http.Request(
      'POST',
      Uri.parse('$apiUrl/oauth/token'),
    );
    refresh.bodyFields = {
      'username': body["user"],
      'password': body["password"],
      'grant_type': 'password',
    };
    refresh.headers.addAll(authHeaders);

    final refreshResponse = await refresh.send();

    if (refreshResponse.statusCode == 200) {
      debugPrint(refreshResponse.statusCode.toString());
      return await refreshResponse.stream
          .bytesToString()
          .then((value) => jsonDecode(value)['access_token']);
    } else {
      retryCount++;
      return await checkAuth(token);
    }
  }
}

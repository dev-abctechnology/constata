import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRefreshController {
  int times = 0;
  Future<String> checkAuth(String token) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'GET', Uri.parse('http://abctech.ddns.net:4230/jarvis/api/'));

    request.headers.addAll(headers);
    try {
      return request.send().then((value) {
        if (value.statusCode != 401) {
          return '';
        }
        if (value.statusCode == 401) {
          return SharedPreferences.getInstance().then(
            (value) {
              var headers = {
                'Authorization': 'Basic amFydmlzQGVmY3MyMDE4OlM0SkJ4NzRv',
                'Content-Type': 'application/x-www-form-urlencoded',
              };
              Map body = jsonDecode(value.getString("authentication"));
              var refresh = http.Request(
                  'POST',
                  Uri.parse(
                      'http://abctech.ddns.net:4230/jarvis/api/oauth/token'));
              refresh.bodyFields = {
                'username': body["user"],
                'password': body["password"],
                'grant_type': 'password'
              };
              refresh.headers.addAll(headers);
              return refresh.send().then(
                (value) {
                  if (value.statusCode == 200) {
                    debugPrint(value.statusCode.toString());
                    return value.stream
                        .bytesToString()
                        .then((value) => jsonDecode(value)['access_token']);
                  } else {
                    if (times < 3) {
                      checkAuth(token);
                      times = times + 1;
                    }
                    return '';
                  }
                },
              );
            },
          );
        }

        return '';
      });
    } catch (e, s) {
      print(e);
      return '';
    }
  }
}

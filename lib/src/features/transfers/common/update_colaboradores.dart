import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateColaborators {
  Future fetchColaboradores(
      {required String token, required String obra}) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-pem-permd-00/filter'));
    request.body = json.encode({
      "filters": [
        {
          "fieldName": "data.tb01_cp123.tp_cp124.name",
          "value": obra,
          "expression": "EQUAL"
        }
      ]
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      SharedPreferences.getInstance().then((value) async => value.setString(
          "colaboradores",
          jsonEncode(jsonDecode(await response.stream.bytesToString()))));
      debugPrint('gravou na memoria');
      return true;
    } else {
      debugPrint(await response.stream.bytesToString());

      return false;
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class CompanyRefreshController {
  static Future<List> refresh(String name, String token) async {
    developer.log('refresh obra', name: "Update");
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjmd-00/filter'));
    request.body =
        '''{"filters": [{"fieldName": "data.tb01_cp002","value": "$name","expression": "EQUAL"}]}''';
    request.headers.addAll(headers);
    print('asfasf');
    try {
      http.StreamedResponse res = await request.send();
      var x = json.decode(await res.stream.bytesToString());
      List value = [];
      if (x is List) {
        value = x;
      }

      developer.log('success', name: "Update");
      return value;
    } catch (e) {
      print(e);
      developer.log('error', name: "Update", error: e);
      return null;
    }
  }
}

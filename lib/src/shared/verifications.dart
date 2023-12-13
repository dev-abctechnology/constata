import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/token.dart';

class Verifications {
  Future<List> checkPresenca(String data, String obra, context) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00/filter'));
    request.body = json.encode({
      "filters": [
        {"fieldName": "data.h0_cp008", "value": data, "expression": "EQUAL"},
        {
          "fieldName": "data.h0_cp013.name",
          "value": obra,
          "expression": "EQUAL"
        }
      ],
      "sort": {"fieldName": "data.h0_cp008", "type": "ASC"},
      "fields": [
        "_id",
        "data.h0_cp008",
        "data.h0_cp009",
        "data.h0_cp013",
        "data.tb01_cp011"
      ]
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List effectiveList = jsonDecode(await response.stream.bytesToString());
      // print(effectiveList);
      debugPrint(response.statusCode.toString());
      return effectiveList;
    } else {
      return [];
    }
  }
}

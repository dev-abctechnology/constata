import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:constata/src/features/effective_process/models/effective_model.dart';
import 'package:constata/src/models/token.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:http/http.dart' as http;

class EffectiveController {
  Future<List<Effective>> fetchEffective(
      {required BuildContext context, required String buildName}) async {
    try {
      var headers = {
        'Authorization':
            'Bearer ${Provider.of<Token>(context, listen: false).token}',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('$apiUrl/stuffdata/sdt_a-pem-permd-00/filter'));
      request.body = json.encode({
        "filters": [
          {
            "fieldName": "data.tb01_cp123.tp_cp124.name",
            "value": buildName,
            "expression": "EQUAL"
          }
        ]
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var effectiveList = jsonDecode(await response.stream.bytesToString());
        List<Effective> effective = [];
        Uuid uuid = const Uuid();

        for (var i = 0; i < effectiveList.length; i++) {
          effective.add(Effective(
              effectiveCode: effectiveList[i]['data']['tb01_cp004'],
              effectiveFixed: '',
              effectiveName: effectiveList[i]['data']['tb01_cp002'],
              effectiveStatus: '',
              id: uuid.v4()));
        }
        return effective;
      } else {
        print(response.reasonPhrase);
        print('a');
        throw Exception();
      }
    } catch (e) {
      print(e);
      throw Exception();
    }
  }

  Future<String> sendEffective(
      {required BuildContext context,
      required EffectiveApointment efetivo}) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('$apiUrl/stuffdata/sdt_a-inm-prjre-00'));
    request.body = jsonEncode(efetivo.toJson());
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        print('Success');
        return 'created';
      } else {
        print((await response.stream.bytesToString()));
        return '${response.statusCode}';
      }
    } catch (e) {
      print(e);
      print('offline store');
      SharedPreferences.getInstance()
          .then((value) => value.setString("filaApontamento", request.body));
      return 'offline';
    }
  }
}

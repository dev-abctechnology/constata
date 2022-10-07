import 'dart:convert';

import 'package:constata_0_0_2/src/features/measurement/model/measurement_object_r.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/token.dart';
import '../../../shared/verifications.dart';

class MeasurementJarvis {
  Future<List<dynamic>> fetchColaborators(
      {BuildContext context, String buildName, String date}) async {
    Verifications verifications = Verifications();
    List colaborators = [];
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
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
          "value": buildName,
          "expression": "EQUAL"
        },
        {
          "fieldName": "data.tb01_cp123.tp_cp132",
          "value": "Sim",
          "expression": "EQUAL"
        },
      ]
    });
    request.headers.addAll(headers);
    print(date);
    print(buildName);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        colaborators = jsonDecode(await response.stream.bytesToString());
        List effective =
            await verifications.checkPresenca(date, buildName, context);
        List effectivePresent;
        if (effective.isNotEmpty) {
          effectivePresent = effective[0]['data']['tb01_cp011'];
        } else {
          effectivePresent = [];
        }

        effectivePresent.removeWhere((element) =>
            element['tp_cp015'] == 'Ausente' ||
            element['tp_cp015'] == 'Em Transferência');
        List effectiveAllowedAndPresent = [];
        for (var i = 0; i < effectivePresent.length; i++) {
          for (var colaborator in colaborators) {
            if (colaborator['data']['tb01_cp002'] ==
                effectivePresent[i]['tp_cp013']) {
              effectiveAllowedAndPresent.add(colaborator);
            }
          }
        }
        return effectiveAllowedAndPresent;
      }
    } catch (e) {
      print(e);

      throw Exception(
          'Falha ao carregar colaboradores. Buscando dados offline');
    }
  }

  Future<String> sendMeasurement(
      MeasurementAppointment data, BuildContext context) async {
    http.Request request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjtm-00'));
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };

    request.body = jsonEncode(data.toJson());
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
          .then((value) => value.setString("filaMedicao", request.body));
      return 'offline';
    }
  }
}

import 'dart:convert';

import 'package:constata/src/features/measurement/model/measurement_object_r.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../models/token.dart';
import '../../../shared/verifications.dart';

class MeasurementJarvis {
  Future<List<dynamic>> fetchColaborators(
      {required BuildContext context,
      required String buildName,
      required String date}) async {
    Verifications verifications = Verifications();
    List colaborators = [];
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
        },
        {
          "fieldName": "data.tb01_cp123.tp_cp132",
          "value": "Sim",
          "expression": "EQUAL"
        },
      ]
    });
    request.headers.addAll(headers);
    debugPrint(date);
    debugPrint(buildName);
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
      } else {
        debugPrint((await response.stream.bytesToString()));
        throw Exception('Falha ao carregar colaboradores');
      }
    } catch (e) {
      debugPrint(e.toString());

      throw Exception(
          'Falha ao carregar colaboradores. Buscando dados offline');
    }
  }

  Future<String> sendMeasurement(
      MeasurementAppointment data, BuildContext context) async {
    http.Request request =
        http.Request('POST', Uri.parse('$apiUrl/stuffdata/sdt_a-inm-prjtm-00'));
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
        debugPrint('Success');
        return 'created';
      } else {
        debugPrint((await response.stream.bytesToString()));
        return '${response.statusCode}';
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('offline store');
      SharedPreferences.getInstance()
          .then((value) => value.setString("filaMedicao", request.body));
      return 'offline';
    }
  }
}

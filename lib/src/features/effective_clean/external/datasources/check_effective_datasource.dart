import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:constata/src/features/effective_clean/data/datasources/check_effective_datasource.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CheckEffectiveDataSourceImpl implements CheckEffectiveDataSource {
  @override
  Future<List<Map<String, dynamic>>> check(DateTime date) async {
    final prefs = SharedPrefs();
    final token = await prefs.getString('token');
    final obra = await prefs.getString('obra');
    final url = Uri.parse('$apiUrl/stuffdata/sdt_a-inm-prjre-00/filter');
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };

    String dateFormated =
        DateFormat('dd/MM/yyyy').format(date ?? DateTime.now());

    try {
      var request = http.Request('POST', url);
      request.body = '''
{
      "filters": [
        {
          "fieldName": "data.h0_cp008",
          "value": "$dateFormated",
          "expression": "CONTAINS"
        },
        {"fieldName":"data.h0_cp013.name","value":"$obra","expression":"CONTAINS"}
      ]
    }

''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        final data = json as List;
        final result = data.map((e) => e as Map<String, dynamic>).toList();

        return result;
      } else {
        throw Exception(
            'Erro ao buscar lançamentos de efetivos - ${response.statusCode} - ${await response.stream.bytesToString()}}');
      }
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception(e.toString());
    }
  }
}

import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:constata/src/features/transfers/data/datasources/get_transfers_datasource.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:constata/src/features/transfers/external/datasources/transfer_mock.dart';
import 'package:http/http.dart' as http;

class GetTransfersDataSouceImpl implements GetTransfersDataSource {
  GetTransfersDataSouceImpl();

  @override
  Future<List<Map<String, dynamic>>> call() async {
    final prefs = SharedPrefs();
    final token = await prefs.getString('token');
    final obraId = await prefs.getString('obra_id');
    print(token);
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      };

      var request = http.Request(
          'POST', Uri.parse('$apiUrl/stuffdata/sdt_t-ran-sfere-00/filter'));
      request.body = '''{
            "filters": [
    {
      "fieldName": "data.tb01_cp005._id",
      "value": "$obraId",
      "expression": "CONTAINS"
    }
  ]
           
          }''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // final result = kTransferMock;

        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        final data = json as List;
        final result = data.map((e) => e as Map<String, dynamic>).toList();

        return result;
      } else {
        print(await response.stream.bytesToString());
        print(response.statusCode);
        throw Exception('Failed to load transfers');
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }
}

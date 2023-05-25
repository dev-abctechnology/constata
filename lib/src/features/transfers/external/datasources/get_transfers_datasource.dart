import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:constata/src/features/transfers/data/datasources/get_transfers_datasource.dart';
import 'package:constata/src/shared/http_client.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:http/http.dart' as http;

class GetTransfersDataSouceImpl implements GetTransfersDataSource {
  GetTransfersDataSouceImpl(this._client);
  final HttpClientAdapter _client;

  @override
  Future<List<Map<String, dynamic>>> call() async {
    final prefs = SharedPrefs();
    final token = await prefs.getString('token');
    print(token);
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      };

      var request = http.Request(
          'POST', Uri.parse('$apiUrl/stuffdata/sdt_a-inm-prjre-00/filter'));
      request.body = '''{
            "filters": [],
            "paginator": {"page": 0, "size": 20},
            "sort": {"fieldName": "data.h0_cp008", "type": "ASC"},
            "type": "TABLE",
            "fields": ["_id", "data.h0_cp008", "data.h0_cp009", "data.h0_cp013"]
          }''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final mock = [
          {
            "nameEffective": "Transfer Entity 1",
            "codeEffective": "TE001",
            "originBuild": "Origin Building A",
            "targetBuild": "Target Building B",
            "status": "Pending",
            "date": "2023-05-25"
          },
          {
            "nameEffective": "Transfer Entity 2",
            "codeEffective": "TE002",
            "originBuild": "Origin Building C",
            "targetBuild": "Target Building D",
            "status": "Completed",
            "date": "2023-05-26"
          },
          {
            "nameEffective": "Transfer Entity 3",
            "codeEffective": "TE003",
            "originBuild": "Origin Building E",
            "targetBuild": "Target Building F",
            "status": "Pending",
            "date": "2023-05-27"
          },
          {
            "nameEffective": "Transfer Entity 4",
            "codeEffective": "TE004",
            "originBuild": "Origin Building G",
            "targetBuild": "Target Building H",
            "status": "Completed",
            "date": "2023-05-28"
          },
          {
            "nameEffective": "Transfer Entity 5",
            "codeEffective": "TE005",
            "originBuild": "Origin Building I",
            "targetBuild": "Target Building J",
            "status": "Pending",
            "date": "2023-05-29"
          }
        ];

        // final body = await response.stream.bytesToString();
        // final json = jsonDecode(body);
        // final data = json['content'] as List;
        // final result =
        //     data.map((e) => e['data'] as Map<String, dynamic>).toList();

        final result = mock;
        return result;
      } else {
        print(response.reasonPhrase);
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

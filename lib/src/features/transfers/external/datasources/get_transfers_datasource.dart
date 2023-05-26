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
        // final mock = [
        //   {
        //     "id": "6470d5317b7191235cd59644",
        //     "ckc": null,
        //     "cko": null,
        //     "createdBy": null,
        //     "created": "2023-05-26T16:06:41.195+0000",
        //     "deleted": false,
        //     "lastUpdate": "2023-05-26T16:06:41.195+0000",
        //     "lastUpdateBy": null,
        //     "data": {
        //       "tb01_cp001": "-00003",
        //       "tb01_cp002": "26/05/2023",
        //       "tb01_cp003": {
        //         "name": "ADAILTON NARCISO PEREIRA",
        //         "_id": "6321dc967b7191293e5dfb68"
        //       },
        //       "tb01_cp004": {
        //         "name": "AGE 360",
        //         "_id": "61b9f0382212ef074ca781e9"
        //       },
        //       "tb01_cp005": {"name": "ALBA", "_id": "6258507f2212ef0f8843f37e"},
        //       "tb01_cp006": "Aguardando"
        //     }
        //   },
        //   {
        //     "id": "6470d5317b7191235cd59644",
        //     "ckc": null,
        //     "cko": null,
        //     "createdBy": null,
        //     "created": "2023-05-26T16:06:41.195+0000",
        //     "deleted": false,
        //     "lastUpdate": "2023-05-26T16:06:41.195+0000",
        //     "lastUpdateBy": null,
        //     "data": {
        //       "tb01_cp001": "-00003",
        //       "tb01_cp002": "26/05/2023",
        //       "tb01_cp003": {
        //         "name": "ADAILTON NARCISO PEREIRA",
        //         "_id": "6321dc967b7191293e5dfb68"
        //       },
        //       "tb01_cp004": {
        //         "name": "AGE 360",
        //         "_id": "61b9f0382212ef074ca781e9"
        //       },
        //       "tb01_cp005": {"name": "ALBA", "_id": "6258507f2212ef0f8843f37e"},
        //       "tb01_cp006": "Aguardando"
        //     }
        //   },
        //   {
        //     "id": "6470d5317b7191235cd59644",
        //     "ckc": null,
        //     "cko": null,
        //     "createdBy": null,
        //     "created": "2023-05-26T16:06:41.195+0000",
        //     "deleted": false,
        //     "lastUpdate": "2023-05-26T16:06:41.195+0000",
        //     "lastUpdateBy": null,
        //     "data": {
        //       "tb01_cp001": "-00003",
        //       "tb01_cp002": "26/05/2023",
        //       "tb01_cp003": {
        //         "name": "ADAILTON NARCISO PEREIRA",
        //         "_id": "6321dc967b7191293e5dfb68"
        //       },
        //       "tb01_cp004": {
        //         "name": "AGE 360",
        //         "_id": "61b9f0382212ef074ca781e9"
        //       },
        //       "tb01_cp005": {"name": "ALBA", "_id": "6258507f2212ef0f8843f37e"},
        //       "tb01_cp006": "Aguardando"
        //     }
        //   }
        // ];

        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        final data = json as List;
        final result = data.map((e) => e as Map<String, dynamic>).toList();

        // final result = mock;
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

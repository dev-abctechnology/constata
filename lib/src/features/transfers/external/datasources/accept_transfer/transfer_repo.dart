import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:constata/src/constants.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/shared/shared_prefs.dart';

class TransferRepository {
  final prefs = SharedPrefs();

  Future<Map<String, dynamic>> getColaborator(String codeEffective) async {
    final token = await prefs.getString('token');

    var headers = {
      "Authorization": "Bearer $token",
    };

    var request = http.Request('GET',
        Uri.parse('$apiUrl/stuffdata/sdt_a-pem-permd-00/$codeEffective'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 202) {
      var body = jsonDecode(await response.stream.bytesToString());
      print(body);
      return {'status': true, 'data': body};
    } else {
      return {
        'status': false,
        'message': 'Erro ao buscar colaborador - code:${response.statusCode}'
      };
    }
  }

  Future<bool> changeBuild(
      TransferEntity entity, Map<String, dynamic> colaborator) async {
    final token = await prefs.getString('token');

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var request =
        http.Request('PUT', Uri.parse('$apiUrl/stuffdata/sdt_a-pem-permd-00'));

    // Replace the object in colaborator['data']['tb01_cp123'][0]['tp_cp124']
    // with {'name': entity.targetBuild, '_id': entity.targetBuildId},
    // the field ['data']['tb01_cp123'][0]['tp_cp126'] to entity.originBuild,
    // and the field ['data']['tb01_cp123'][0]['tp_cp136'] to entity.targetBuild
    colaborator['data']['tb01_cp123'][0]['tp_cp124'] = {
      'name': entity.targetBuild,
      '_id': entity.targetBuildId,
    };
    colaborator['data']['tb01_cp123'][0]['tp_cp126'] = entity.originBuild;
    colaborator['data']['tb01_cp123'][0]['tp_cp136'] = entity.targetBuild;

    request.body = jsonEncode(colaborator);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  Future<Map<String, dynamic>> getTransfer(String transferId) async {
    String token = await prefs.getString('token');

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var request = http.Request(
        'GET', Uri.parse('$apiUrl/stuffdata/sdt_t-ran-sfere-00/$transferId'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 202) {
        var body = jsonDecode(await response.stream.bytesToString());
        print(body);
        return {'status': true, 'data': body};
      } else {
        return {
          'status': false,
          'message':
              'Erro ao buscar transferência - code:${response.statusCode}'
        };
      }
    } catch (e, s) {
      print(e);
      print(s);
      return {'status': false, 'message': 'Erro ao buscar transferência'};
    }
  }

  Future<bool> changeTransfer(TransferEntity entity,
      Map<String, dynamic> transfer, String label) async {
    final token = await prefs.getString('token');

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var request =
        http.Request('PUT', Uri.parse('$apiUrl/stuffdata/sdt_t-ran-sfere-00'));

    transfer['data']['tb01_cp006'] = label;

    request.body = jsonEncode(transfer);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }
}

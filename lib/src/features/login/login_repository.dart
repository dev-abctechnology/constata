import 'dart:convert';

import 'package:constata/src/shared/constants.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class LoginRepository {
  String? token;

  final Dio client;
  LoginRepository(this.client);
  Future<String> generateToken(String username, String password) async {
    try {
      final response = await client.post(
        '$kUrlJarvis/oauth/token',
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password'
        },
        options: Options(
          headers: {
            'Authorization': 'Basic amFydmlzQGVmY3MyMDE4OlM0SkJ4NzRv',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      token = response.data['access_token'];
      return response.data['access_token'];
    } on DioException catch (e) {
      print(e.stackTrace);
      print(e.toString());
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          throw Exception('Usuário ou senha inválidos');
        }
        throw Exception('Falha ao entrar no sistema');
      }
    }

    throw Exception('Falha ao entrar no sistema');
  }

  Future<Map<String, dynamic>> fetchUserSigned(String username) async {
    try {
      final response = await client.post(
        '$kUrlJarvis/users/filter',
        data: {
          "filters": [
            {"fieldName": "ckc", "value": "CONPROD001", "expression": "EQUAL"},
            {"fieldName": "username", "value": username, "expression": "EQUAL"}
          ]
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );

      final user = response.data[0];
      return user;
    } on DioException catch (e) {
      if (e.response!.statusCode == 400) {
        throw Exception('Usuário ou senha inválidos');
      }
      throw Exception('Falha ao entrar no sistema');
    }
  }

  Future<Map<String, dynamic>> pegarParceiroDeNegocio(String username) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    var request = http.Request(
        'POST', Uri.parse('$kUrlJarvis/stuffdata/sdt_a-pem-permd-00/filter'));
    request.body = json.encode({
      "filters": [
        {
          "fieldName": "data.tb01_cp137.name",
          "value": username,
          "expression": "EQUAL"
        }
      ]
    });

    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        try {
          final responseData =
              jsonDecode(await response.stream.bytesToString());
          final collaborators = responseData[0]['data'];
          return collaborators;
        } catch (e, s) {
          print(e);
          print(s);
          throw Exception(jsonDecode(await response.stream.bytesToString()));
        }
      } else {
        throw Exception('Falha ao baixar dados do usuário');
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

//fetch obras
  Future<List> fetchObras(String username) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    var request = http.Request(
      'POST',
      Uri.parse(
        '$kUrlJarvis/stuffdata/sdt_a-inm-prjmd-00/filter',
      ),
    );
    request.body = '''

      {
        "filters": [
          {
            "fieldName": "data.tb03_cp008.tp_cp009",
            "value": "$username",
            "expression": "EQUAL"
          }
        ]
      }
    }

''';

    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final obras = jsonDecode(await response.stream.bytesToString());
        return obras;
      } else {
        throw Exception(await response.stream.bytesToString());
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }
}

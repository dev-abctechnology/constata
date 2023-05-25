import 'package:http/http.dart' as http;

class HttpClientAdapter {
  HttpClientAdapter() {
    client = http.Client();
  }

  http.Client client;

  Future<dynamic> get({
    String path,
    queryParameters,
    headers,
  }) async {
    try {
      final uri = Uri.parse(path);
      final response = await client.get(uri, headers: headers);
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post({
    String path,
    body,
    headers,
  }) async {
    try {
      final uri = Uri.parse(path);
      final response = await client.post(uri, body: body, headers: headers);
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put({
    String path,
    body,
    headers,
  }) async {
    try {
      final uri = Uri.parse(path);
      final response = await client.put(uri, body: body, headers: headers);
      return response.body;
    } catch (e) {
      rethrow;
    }
  }
}

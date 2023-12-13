import 'package:constata/src/constants.dart';
import 'package:constata/src/features/transfers/data/datasources/create_transfer_datasource.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/shared/custom_either.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:http/http.dart' as http;

class CreateTransferDataSourceImpl implements CreateTransferDataSource {
  @override
  Future<ResponseEither> call(TransferEntity transfer) async {
    final prefs = SharedPrefs();
    final token = await prefs.getString('token');

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };

    var request =
        http.Request('POST', Uri.parse('$apiUrl/stuffdata/sdt_t-ran-sfere-00'));

    request.body = transfer.toString();

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var body = await response.stream.bytesToString();
    print(body);
    if (response.statusCode == 201) {
      return ResponseEither.success(true);
    } else {
      return ResponseEither(
          status: false,
          message: 'Erro ao criar transferência - code:${response.statusCode}',
          data: null,
          stackTrace: null);
    }
  }
}

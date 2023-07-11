import 'package:constata/src/features/transfers/data/datasources/create_transfer_datasource.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/repositories/create_transfer_repository.dart';

class CreateTransferRepositoryImpl implements CreateTransferRepository {
  CreateTransferRepositoryImpl(this.dataSource);

  final CreateTransferDataSource dataSource;

  @override
  Future<bool> call(TransferEntity params) async {
    try {
      final response = await dataSource(params);
      if (response.status == false) {
        throw Exception(response.message);
      } else {
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }
}

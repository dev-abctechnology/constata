import '../entities/transfer_entity.dart';

abstract class CreateTransferRepository {
  Future<bool> call(TransferEntity params);
}

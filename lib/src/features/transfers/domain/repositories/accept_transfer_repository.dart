import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';

abstract class AcceptTransferRepository {
  Future<bool> call(TransferEntity params, String label);
  Future<bool> deny(TransferEntity params, String label);
}

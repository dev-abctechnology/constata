import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/shared/custom_either.dart';

abstract class AcceptTransferDataSource {
  Future<ResponseEither> call(TransferEntity transfer, String label);

  Future<ResponseEither> deny(TransferEntity transfer, String label);
}

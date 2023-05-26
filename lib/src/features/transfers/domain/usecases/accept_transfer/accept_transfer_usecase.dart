import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/shared/custom_either.dart';

abstract class AcceptTransferUseCase {
  Future<ResponseEither> call(TransferEntity transferEntity, String label);
  Future<ResponseEither> deny(TransferEntity transferEntity, String label);
}

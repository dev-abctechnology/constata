import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/shared/custom_either.dart';

abstract class CreateTransferDataSource {
  Future<ResponseEither> call(TransferEntity transfer);
}

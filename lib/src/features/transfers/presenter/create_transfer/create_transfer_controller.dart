import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/create_transfer/create_transfer_usecase.dart';

class CreateTransferController {
  CreateTransferController(this._createTransferUseCase, this.transferEntity);
  final CreateTransferUseCase _createTransferUseCase;
  final TransferEntity transferEntity;

  Future<bool> createTransfer() async {
    try {
      final responseEither = await _createTransferUseCase(transferEntity);

      if (responseEither.status == false) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}

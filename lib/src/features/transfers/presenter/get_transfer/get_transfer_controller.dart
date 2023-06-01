import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/accept_transfer/accept_transfer_usecase.dart';
import 'package:constata/src/features/transfers/domain/usecases/get_transfers/get_transfers_usecase.dart';
import 'package:constata/src/shared/custom_either.dart';

class TransferController {
  TransferController(this._getTransfersUseCase, this._acceptTransferUseCase);

  final GetTransfersUseCase _getTransfersUseCase;
  final AcceptTransferUseCase _acceptTransferUseCase;

  List<TransferEntity> _transfers = [];
  List<TransferEntity> get transfers => _transfers;

  Future<bool> acceptTransfer(TransferEntity transfer) async {
    try {
      ResponseEither response =
          await _acceptTransferUseCase(transfer, 'Concluído');
      if (response.status == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> denyTransfer(TransferEntity transfer) async {
    try {
      ResponseEither response =
          await _acceptTransferUseCase.deny(transfer, 'Negado');
      if (response.status == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getTransfers() async {
    try {
      ResponseEither response = await _getTransfersUseCase();
      if (response.status == true) {
        _transfers = response.data as List<TransferEntity>;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}

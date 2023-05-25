import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/get_transfers/get_transfers_usecase.dart';
import 'package:constata/src/shared/custom_either.dart';

class TransferController {
  TransferController(this._getTransfersUseCase);

  final GetTransfersUseCase _getTransfersUseCase;

  List<TransferEntity> _transfers = [];
  List<TransferEntity> get transfers => _transfers;

  Future<void> getTransfers() async {
    try {
      ResponseEither response = await _getTransfersUseCase();
      response.status == true
          ? _transfers = response.data as List<TransferEntity>
          : throw Exception(response.message);
    } catch (e, s) {
      rethrow;
    }
  }
}

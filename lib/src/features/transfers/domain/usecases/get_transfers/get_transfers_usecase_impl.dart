import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/repositories/get_transfers_repository.dart';
import 'package:constata/src/shared/custom_either.dart';
import 'package:constata/src/shared/errors/exceptions.dart';

import 'get_transfers_usecase.dart';

class GetTransfersUseCaseImpl implements GetTransfersUseCase {
  GetTransfersUseCaseImpl(this.repository);

  final GetTransfersRepository repository;

  @override
  Future<ResponseEither> call() async {
    try {
      final List<TransferEntity> transfers = await repository();
      return ResponseEither.success(transfers);
    } on TransferExceptionRepo catch (e, s) {
      return ResponseEither.exception(e.message, s);
    } catch (e, s) {
      return ResponseEither.exception(e.toString(), s);
    }
  }
}

import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/repositories/accept_transfer_repository.dart';
import 'package:constata/src/features/transfers/domain/usecases/accept_transfer/accept_transfer_usecase.dart';
import 'package:constata/src/shared/custom_either.dart';

class AcceptTransferUseCaseImpl implements AcceptTransferUseCase {
  AcceptTransferUseCaseImpl(this._acceptTransferRepository);
  final AcceptTransferRepository _acceptTransferRepository;

  @override
  Future<ResponseEither> call(
      TransferEntity transferEntity, String label) async {
    try {
      final bool response =
          await _acceptTransferRepository(transferEntity, label);
      if (response) {
        return ResponseEither.success(true);
      } else {
        return ResponseEither.error('Erro ao aceitar transferência!');
      }
    } catch (e, s) {
      return ResponseEither.exception('Erro ao aceitar transferência! - $e', s);
    }
  }

  @override
  Future<ResponseEither> deny(
      TransferEntity transferEntity, String label) async {
    try {
      final bool response =
          await _acceptTransferRepository.deny(transferEntity, label);
      if (response) {
        return ResponseEither.success(true);
      } else {
        return ResponseEither.error('Erro ao negar transferência!');
      }
    } catch (e, s) {
      return ResponseEither.exception('Erro ao negar transferência! - $e', s);
    }
  }
}

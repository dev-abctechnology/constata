import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/usecases/create_transfer/create_transfer_usecase.dart';
import 'package:constata/src/shared/custom_either.dart';

import '../../repositories/create_transfer_repository.dart';

class CreateTransferUseCaseImpl implements CreateTransferUseCase {
  CreateTransferUseCaseImpl(this.repository);

  final CreateTransferRepository repository;

  @override
  Future<ResponseEither> call(TransferEntity params) async {
    try {
      await repository(params);
      return ResponseEither.success(true);
    } catch (e, s) {
      return ResponseEither.exception(e.toString(), s);
    }
  }
}

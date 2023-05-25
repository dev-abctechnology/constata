import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';

abstract class GetTransfersRepository {
  Future<List<TransferEntity>> call();
}

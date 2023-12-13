import 'package:constata/src/features/transfers/data/datasources/accept_transfer_datasource.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/external/datasources/accept_transfer/transfer_repo.dart';
import 'package:constata/src/shared/custom_either.dart';
import 'package:constata/src/shared/shared_prefs.dart';
import 'package:flutter/foundation.dart';

class AcceptTransferDataSourceImpl implements AcceptTransferDataSource {
  final prefs = SharedPrefs();
  final TransferRepository repository = TransferRepository();

  @override
  Future<ResponseEither> call(TransferEntity transfer, String label) async {
    try {
      final colaborator =
          await repository.getColaborator(transfer.codeEffective!);
      if (colaborator['status'] == false) {
        throw Exception(colaborator['message']);
      } else {
        final response =
            await repository.changeBuild(transfer, colaborator['data']);
        if (response == false) {
          throw Exception('Erro ao alterar o colaborador');
        } else {
          final updateResponse = await updateTransferQueue(transfer, label);
          if (updateResponse.status) {
            return ResponseEither(status: true);
          } else {
            throw Exception(updateResponse.message);
          }
        }
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return ResponseEither(status: false, message: e.toString());
    }
  }

  Future<ResponseEither> updateTransferQueue(
      TransferEntity entity, String label) async {
    try {
      final transfer = await repository.getTransfer(entity.id!);
      if (transfer['status'] == false) {
        throw Exception(transfer['message']);
      } else {
        final response =
            await repository.changeTransfer(entity, transfer['data'], label);
        if (response == false) {
          throw Exception('Erro ao atualizar transferência');
        } else {
          return ResponseEither(status: true);
        }
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return ResponseEither(status: false, message: e.toString());
    }
  }

  @override
  Future<ResponseEither> deny(TransferEntity transfer, String label) async {
    try {
      final updateResponse = await updateTransferQueue(transfer, label);
      if (updateResponse.status) {
        return ResponseEither(status: true);
      } else {
        throw Exception(updateResponse.message);
      }
    } catch (e, s) {
      debugPrint(e.toString());
      return ResponseEither.exception(e.toString(), s);
    }
  }
}

import 'package:constata/src/features/transfers/data/datasources/accept_transfer_datasource.dart';
import 'package:constata/src/features/transfers/domain/entities/transfer_entity.dart';
import 'package:constata/src/features/transfers/domain/repositories/accept_transfer_repository.dart';
import 'package:flutter/material.dart';

class AcceptTransferRepositoryImpl implements AcceptTransferRepository {
  AcceptTransferRepositoryImpl(this._acceptTransferDataSource);
  final AcceptTransferDataSource _acceptTransferDataSource;

  @override
  Future<bool> call(TransferEntity params, String label) async {
    try {
      final response = await _acceptTransferDataSource(params, label);
      if (response.status == false) {
        throw Exception(response.message);
      } else {
        return true;
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      rethrow;
    }
  }

  @override
  Future<bool> deny(TransferEntity params, String label) async {
    try {
      final response = await _acceptTransferDataSource.deny(params, label);
      if (response.status == false) {
        throw Exception(response.message);
      } else {
        return true;
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      rethrow;
    }
  }
}

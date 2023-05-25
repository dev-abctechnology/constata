import 'package:constata/src/features/transfers/data/datasources/get_transfers_datasource.dart';
import 'package:constata/src/features/transfers/domain/repositories/get_transfers_repository.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/transfer_entity.dart';

class GetTransfersRepositoryImpl implements GetTransfersRepository {
  GetTransfersRepositoryImpl(this.dataSource);

  final GetTransfersDataSource dataSource;

  @override
  Future<List<TransferEntity>> call() async {
    try {
      final List<Map<String, dynamic>> transfers = await dataSource();
      return transfers.map((e) => TransferEntity.fromMap(e)).toList();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      rethrow;
    }
  }
}

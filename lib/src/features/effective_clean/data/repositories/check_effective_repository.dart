import 'package:constata/src/features/effective_clean/data/datasources/check_effective_datasource.dart';
import 'package:constata/src/features/effective_clean/domain/repositories/check_effective_repository.dart';
import 'package:constata/src/features/effective_process/models/effective_model.dart';

class CheckEffectiveRepositoryImpl implements CheckEffectiveRepository {
  CheckEffectiveRepositoryImpl(this._dataSource);

  final CheckEffectiveDataSource _dataSource;

  @override
  Future<List<EffectiveApointment>> check(DateTime date) async {
    try {
      final List<Map<String, dynamic>> effectiveApointments =
          await _dataSource.check(date);
      return effectiveApointments
          .map((e) => EffectiveApointment.fromJson(e))
          .toList();
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception(e.toString());
    }
  }
}

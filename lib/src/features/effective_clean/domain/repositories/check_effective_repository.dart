import 'package:constata/src/features/effective_process/models/effective_model.dart';

abstract class CheckEffectiveRepository {
  Future<List<EffectiveApointment>> check(DateTime date);
}

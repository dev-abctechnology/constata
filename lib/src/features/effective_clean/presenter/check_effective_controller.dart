import 'package:constata/src/features/effective_clean/domain/usecases/check_effective_usecase.dart';
import 'package:constata/src/features/effective_process/models/effective_model.dart';

class CheckEffectiveController {
  CheckEffectiveController(this._checkEffectiveUseCase);

  final CheckEffectiveUseCase _checkEffectiveUseCase;

  List<EffectiveApointment> _effectiveApointments = [];

  List<EffectiveApointment> get effectiveApointments => _effectiveApointments;

  Future<bool> checkEffective(DateTime date) async {
    try {
      final response = await _checkEffectiveUseCase(date);
      if (response.status == true) {
        _effectiveApointments = response.data;
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }
}

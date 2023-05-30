import 'package:constata/src/features/effective_clean/domain/repositories/check_effective_repository.dart';
import 'package:constata/src/features/effective_clean/domain/usecases/check_effective_usecase.dart';
import 'package:constata/src/features/effective_process/models/effective_model.dart';
import 'package:constata/src/shared/custom_either.dart';

class CheckEffectiveUseCaseImpl implements CheckEffectiveUseCase {
  CheckEffectiveUseCaseImpl(this._repository);

  final CheckEffectiveRepository _repository;

  @override
  Future<ResponseEither> call(DateTime date) async {
    try {
      final List<EffectiveApointment> effectiveApointments =
          await _repository.check(date);
      return ResponseEither.success(effectiveApointments);
    } catch (e, s) {
      return ResponseEither.error(e.toString(), s);
    }
  }
}

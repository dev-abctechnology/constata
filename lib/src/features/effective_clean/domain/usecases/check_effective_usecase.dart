import 'package:constata/src/shared/custom_either.dart';

abstract class CheckEffectiveUseCase {
  Future<ResponseEither> call(DateTime date);
}

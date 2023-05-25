import 'package:constata/src/shared/custom_either.dart';

abstract class GetTransfersUseCase {
  Future<ResponseEither> call();
}

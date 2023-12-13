import 'package:jwt_decoder/jwt_decoder.dart';

class AuthUtils {
  bool isTokenExpired(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int expirationDate = decodedToken['exp'];
    return DateTime.now().millisecondsSinceEpoch > expirationDate * 1000;
  }
}

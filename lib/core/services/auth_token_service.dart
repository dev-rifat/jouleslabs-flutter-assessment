
import '../utils/app_string.dart';
import 'local_store_service.dart';

class AuthTokenService {
  AuthTokenService(this._localStoreService);
  final LocalStoreService _localStoreService;

  /// Store access token  & refresh token securely
  Future storeAuthTokens(String accessToken) async {
    await Future.wait<void>([
      _localStoreService.write(AppString.ACCESS_TOKEN, accessToken),
    ]);
  }

  /// Retrieve the access token securely
  Future<String?> getAccessToken() async {
    return await _localStoreService.read(AppString.ACCESS_TOKEN);
  }



  /// Delete both access and refresh tokens securely
  Future<void> deleteTokens() async {
    await Future.wait<void>([
      _localStoreService.delete(AppString.ACCESS_TOKEN),
    ]);
  }




}

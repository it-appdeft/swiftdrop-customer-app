import 'dart:convert';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../constants/storage_keys.dart';
import '../network/dio_client.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isAuthenticated => StorageService.to.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    _loadStoredUser();
  }

  void _loadStoredUser() {
    try {
      final userJson = StorageService.to.read<String>(StorageKeys.userData);
      if (userJson != null && userJson.isNotEmpty) {
        currentUser.value = UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      AppLogger.w('Failed to load stored user', e);
    }
  }

  Future<void> saveSession({
    required String accessToken,
    String refreshToken = '',
    required UserModel user,
  }) async {
    await StorageService.to.write(StorageKeys.authToken, accessToken);
    if (refreshToken.isNotEmpty) {
      await StorageService.to.write(StorageKeys.refreshToken, refreshToken);
    }
    await StorageService.to.write(StorageKeys.userData, jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  Future<void> logout() async {
    await StorageService.to.clearAuth();
    DioClient.reset();
    currentUser.value = null;
  }
}

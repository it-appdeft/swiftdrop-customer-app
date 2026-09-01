import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../data/models/address_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../constants/storage_keys.dart';
import '../network/dio_client.dart';
import '../utils/app_logger.dart';
import 'notification_service.dart';
import 'realtime_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);

  bool get isAuthenticated => StorageService.to.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    _loadStoredUser();
    _loadStoredAddress();

    if (isAuthenticated && currentUser.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentUser.value != null) {
          _connectRealtime(currentUser.value!);
        }
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.to.syncFcmTokenWithServer();
        }
      });
    }
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

  void _loadStoredAddress() {
    try {
      final addrJson = StorageService.to.read<String>(StorageKeys.selectedAddress);
      if (addrJson != null && addrJson.isNotEmpty) {
        selectedAddress.value = AddressModel.fromJson(jsonDecode(addrJson));
      }
    } catch (e) {
      AppLogger.w('Failed to load stored address', e);
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

    _connectRealtime(user);
    if (Get.isRegistered<NotificationService>()) {
      NotificationService.to.syncFcmTokenWithServer();
    }
  }

  Future<void> saveSelectedAddress(AddressModel? address) async {
    if (address == null) {
      await StorageService.to.remove(StorageKeys.selectedAddress);
      selectedAddress.value = null;
      return;
    }
    await StorageService.to.write(
      StorageKeys.selectedAddress,
      jsonEncode(address.toJson()),
    );
    selectedAddress.value = address;
  }

  Future<void> logout() async {
    if (Get.isRegistered<RealtimeService>()) {
      RealtimeService.to.disconnect();
    }
    try {
      await AuthRepository().logout();
    } catch (e) {
      AppLogger.w('[AUTH] logout API call failed — clearing local state anyway', e);
    }
    await StorageService.to.clearAuth();
    DioClient.reset();
    currentUser.value = null;
    selectedAddress.value = null;
  }

  // ─── Reverb Connection ─────────────────────────────────────────────────────

  void _connectRealtime(UserModel user) {
    if (!Get.isRegistered<RealtimeService>()) return;
    final realtime = RealtimeService.to;
    realtime.connect().then((_) {
      final userId = user.id;
      if (userId.toString().isNotEmpty) {
        realtime.subscribeUser(userId);
      }
    });
  }
}
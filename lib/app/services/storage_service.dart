import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late final GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  bool get isLoggedIn {
    final token = read<String>(StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuth() async {
    await remove(StorageKeys.authToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.userData);
    await remove(StorageKeys.selectedAddress);
  }
}

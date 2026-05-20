import 'package:get/get.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsRepository>(() => EarningsRepository());
    Get.lazyPut<WalletController>(() => WalletController(Get.find()));
  }
}

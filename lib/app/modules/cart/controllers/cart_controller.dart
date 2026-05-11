import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final RxInt quantity;

  CartItem({required this.id, required this.name, required this.price, int qty = 1})
      : quantity = qty.obs;
}

class CartController extends BaseController {
  final items = <CartItem>[].obs;
  final RxDouble deliveryFee = 2.99.obs;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity.value);
  double get total => subtotal + deliveryFee.value;

  void addItem(String id, String name, double price) {
    final existing = items.firstWhereOrNull((i) => i.id == id);
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(CartItem(id: id, name: name, price: price));
    }
  }

  void removeItem(String id) {
    items.removeWhere((i) => i.id == id);
  }

  void decrementItem(String id) {
    final existing = items.firstWhereOrNull((i) => i.id == id);
    if (existing == null) return;
    if (existing.quantity.value <= 1) {
      items.remove(existing);
    } else {
      existing.quantity.value--;
    }
  }

  void clearCart() => items.clear();

  void proceedToCheckout() => Get.toNamed(AppRoutes.checkout);
}

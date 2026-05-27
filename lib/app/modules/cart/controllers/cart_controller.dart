import '../../../../export.dart';

class CartItem {
  final String id;
  final String name;
  final String? addons;
  final double price;
  final RxInt quantity;
  final String? image;
  final RxBool isExpanded = false.obs;

  CartItem({
    required this.id,
    required this.name,
    this.addons,
    required this.price,
    int qty = 1,
    this.image,
  }) : quantity = qty.obs;
}

class Coupon {
  final String title;
  final String offerAmount;
  final String description;
  final String code;
  final String? validOn;
  final bool isExclusive;

  Coupon({
    required this.title,
    required this.offerAmount,
    required this.description,
    required this.code,
    this.validOn,
    this.isExclusive = false,
  });
}

class CartController extends BaseController {
  final _repo = CartRepository();

  final items = <CartItem>[].obs;
  final coupons = <Coupon>[].obs;
  final RxDouble deliveryFee = 2.20.obs;
  final RxDouble taxesAndCharges = 1.20.obs;

  // API-sourced cart state
  final quantities = <int, int>{}.obs; // menuItemId → quantity
  final cartApiItems = <CartApiItem>[].obs;
  final RxString cartRestaurantName = ''.obs;
  final RxString cartRestaurantLogo = ''.obs;
  final RxInt cartItemCount = 0.obs;

  // Cooking Request states
  final RxString cookingRequest = ''.obs;
  final RxBool isCookingRequestExpanded = false.obs;
  final RxBool isCookingRequestSaved = false.obs;
  final RxString cookingRequestTemp = ''.obs;
  final cookingRequestController = TextEditingController();

  // Coupon states
  final RxBool isCouponApplied = false.obs;
  final RxDouble couponDiscount = 12.00.obs;

  @override
  void onInit() {
    super.onInit();
    _populateCoupons();
    cookingRequestController.addListener(() {
      cookingRequestTemp.value = cookingRequestController.text;
    });
    fetchCart();
  }

  void _populateCoupons() {
    coupons.clear();
    coupons.addAll([
      Coupon(
        title: 'EXCLUSIVE WELCOME',
        offerAmount: '50% OFF',
        description: 'On Your First Three Orders',
        code: 'WELCOME50',
        isExclusive: true,
      ),
      Coupon(
        title: 'Weekend Special',
        offerAmount: '£10 OFF',
        description: 'Get £10 OFF on all orders above £45 during the weekend.',
        code: 'WEEKEND20',
      ),
      Coupon(
        title: 'Free Delivery',
        offerAmount: 'FREE',
        description: 'Zero delivery fees on all orders from Premium Partners.',
        code: 'FREEDEL',
        validOn: 'Valid on orders > £30',
      ),
    ]);
  }

  Future<void> fetchCart() async {
    final result = await _repo.getCart();
    if (result.success && result.data != null) {
      final cart = result.data!;
      final newQty = <int, int>{};
      final newItems = <CartItem>[];
      for (final item in cart.items) {
        newQty[item.menuItemId] = (newQty[item.menuItemId] ?? 0) + item.quantity;
        final addonsStr = item.modifiers.isNotEmpty
            ? item.modifiers.map((m) => m.optionName).join(', ')
            : null;
        newItems.add(CartItem(
          id: item.id.toString(),
          name: item.name,
          addons: addonsStr,
          price: item.unitPrice,
          qty: item.quantity,
          image: item.imageUrl,
        ));
      }
      quantities.value = newQty;
      items.value = newItems;
      cartApiItems.value = cart.items;
      cartRestaurantName.value = cart.restaurantName ?? '';
      cartRestaurantLogo.value = cart.restaurantLogoUrl ?? '';
      cartItemCount.value = cart.itemCount;
    }
  }

  void _syncItemCount() {
    cartItemCount.value = quantities.values.fold(0, (sum, q) => sum + q);
  }

  Future<void> addToCartApi(
      int menuItemId, List<int> options, int quantity) async {
    quantities[menuItemId] = (quantities[menuItemId] ?? 0) + quantity;
    _syncItemCount();

    final result = await _repo.addToCart(
        menuItemId: menuItemId, options: options, quantity: quantity);
    if (result.success) {
      await fetchCart();
    } else {
      final reverted = (quantities[menuItemId] ?? quantity) - quantity;
      if (reverted <= 0) {
        quantities.remove(menuItemId);
      } else {
        quantities[menuItemId] = reverted;
      }
      _syncItemCount();
    }
  }

  List<CartApiModifier> getModifiersForItem(int menuItemId) {
    for (final item in cartApiItems) {
      if (item.menuItemId == menuItemId) return item.modifiers;
    }
    return [];
  }

  double get itemTotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity.value);

  double get totalToPay {
    double total = itemTotal + deliveryFee.value + taxesAndCharges.value;
    if (isCouponApplied.value) {
      total -= couponDiscount.value;
    }
    return total;
  }

  void addItem(String id) {
    final existing = items.firstWhereOrNull((i) => i.id == id);
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(CartItem(id: id, name: 'New Item', price: 0, qty: 1));
    }
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

  void toggleCookingRequest() {
    isCookingRequestExpanded.value = !isCookingRequestExpanded.value;
    if (isCookingRequestExpanded.value) {
      cookingRequestTemp.value = cookingRequest.value;
      cookingRequestController.text = cookingRequest.value;
    }
  }

  void saveCookingRequest() {
    final text = cookingRequestController.text.trim();
    if (text.isEmpty) {
      AppUtils.showError('Please enter valid cooking requests or cancel.');
      return;
    }
    cookingRequest.value = text;
    isCookingRequestSaved.value = true;
    isCookingRequestExpanded.value = false;
  }

  void editCookingRequest() {
    isCookingRequestExpanded.value = true;
    cookingRequestTemp.value = cookingRequest.value;
    cookingRequestController.text = cookingRequest.value;
  }

  void clearCookingRequest() {
    cookingRequest.value = '';
    cookingRequestTemp.value = '';
    cookingRequestController.clear();
    isCookingRequestSaved.value = false;
  }

  Future<void> incrementCartItem(int menuItemId) async {
    int? cartItemId;
    int currentQty = 0;
    for (final item in cartApiItems) {
      if (item.menuItemId == menuItemId) {
        cartItemId = item.id;
        currentQty = item.quantity;
        break;
      }
    }
    if (cartItemId == null) return;

    quantities[menuItemId] = (quantities[menuItemId] ?? 0) + 1;
    _syncItemCount();

    final result =
        await _repo.updateCartItemQuantity(cartItemId, currentQty + 1);
    if (result.success) {
      await fetchCart();
    } else {
      final reverted = (quantities[menuItemId] ?? 1) - 1;
      if (reverted <= 0) {
        quantities.remove(menuItemId);
      } else {
        quantities[menuItemId] = reverted;
      }
      _syncItemCount();
    }
  }

  Future<void> removeFromCartApi(int menuItemId) async {
    int? cartItemId;
    for (final item in cartApiItems) {
      if (item.menuItemId == menuItemId) {
        cartItemId = item.id;
        break;
      }
    }
    if (cartItemId == null) return;

    final prevQty = quantities[menuItemId] ?? 0;
    if (prevQty <= 1) {
      quantities.remove(menuItemId);
      items.removeWhere((i) => i.id == cartItemId.toString());
    } else {
      quantities[menuItemId] = prevQty - 1;
    }
    _syncItemCount();

    final result = await _repo.removeCartItem(cartItemId);
    if (result.success) {
      await fetchCart();
    } else {
      quantities[menuItemId] = prevQty;
      _syncItemCount();
      if (prevQty <= 1) await fetchCart();
    }
  }

  Future<void> clearCartApi() async {
    await _repo.clearCart();
    quantities.clear();
    items.clear();
    cartApiItems.clear();
    cartItemCount.value = 0;
    cartRestaurantName.value = '';
    cartRestaurantLogo.value = '';
  }

  void applyCoupon() => isCouponApplied.value = true;
  void removeCoupon() => isCouponApplied.value = false;
  void clearCart() => items.clear();
  void proceedToPlaceOrder() => Get.toNamed(AppRoutes.checkout);
}

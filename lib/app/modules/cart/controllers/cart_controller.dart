import 'package:swiftdrop_customer_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:swiftdrop_customer_app/app/modules/order_history/controllers/order_history_controller.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

import '../../../../export.dart';
import '../widgets/coupon_applied_dialog.dart';

class CartItem {
  final String id;
  final int menuItemId;
  final String name;
  final String? description;
  final String? addons;
  final bool isVeg;
  final double price;
  final double basePrice;
  final RxInt quantity;
  final String? image;
  final RxBool isExpanded = false.obs;
  final bool isAvailable;
  final List<ModifierGroupModel> modifierGroups;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    this.description,
    this.addons,
    this.isVeg = true,
    required this.price,
    double? basePrice,
    int qty = 1,
    this.image,
    this.isAvailable = true,
    this.modifierGroups = const [],
  })  : basePrice = basePrice ?? price,
        quantity = qty.obs;

  bool get hasModifiers => modifierGroups.isNotEmpty;

  Map<String, dynamic> toMap({int? restaurantId}) => {
        'id': menuItemId,
        'cart_item_id': id,
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'base_price': basePrice.toStringAsFixed(2),
        'isVeg': isVeg,
        'image': image,
        'modifier_groups': modifierGroups,
        'restaurant_id': restaurantId,
      };
}

class CartController extends BaseController {
  final _repo = CartRepository();

  final items = <CartItem>[].obs;
  final RxDouble deliveryFee = 2.20.obs;
  final RxDouble taxesAndCharges = 1.20.obs;

  // API-sourced cart state
  final quantities = <int, int>{}.obs; // menuItemId → quantity
  final loadingItems = <int>{}.obs; // menuItemId → loading state
  final loadingButtons = <String>{}.obs; // "cartItemId-plus" or "cartItemId-minus"
  final cartApiItems = <CartApiItem>[].obs;
  final RxString cartRestaurantName = ''.obs;
  final RxString cartRestaurantLogo = ''.obs;
  final RxInt cartItemCount = 0.obs;
  final RxInt cartRestaurantId = 0.obs;

  // Checkout summary
  final checkoutData = Rx<CheckoutModel?>(null);

  // Cooking Request states
  final RxString cookingRequest = ''.obs;
  final RxBool isCookingRequestExpanded = false.obs;
  final RxBool isCookingRequestSaved = false.obs;
  final RxString cookingRequestTemp = ''.obs;
  final cookingRequestController = TextEditingController();
  final RxBool isSavingCookingRequest = false.obs;

  // Coupon states
  final RxBool isCouponApplied = false.obs;
  final RxDouble couponDiscount = 12.00.obs;

  // Order state
  final RxBool isPlacingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    cookingRequestController.addListener(() {
      cookingRequestTemp.value = cookingRequestController.text;
    });
    if (Get.isRegistered<AuthService>() && AuthService.to.isAuthenticated) {
      Future.wait([fetchCart(), fetchCheckout()]);
    }
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
          menuItemId: item.menuItemId,
          name: item.name,
          description: item.description,
          addons: addonsStr,
          price: item.unitPrice,
          basePrice: item.basePrice,
          qty: item.quantity,
          image: item.imageUrl,
          isVeg: item.isVeg,
          modifierGroups: item.modifierGroups,
        ));
      }
      quantities.value = newQty;
      items.value = newItems;
      cartApiItems.value = cart.items;
      cartRestaurantName.value = cart.restaurantName ?? '';
      cartRestaurantLogo.value = cart.restaurantLogoUrl ?? '';
      cartItemCount.value = cart.itemCount;
      if (cart.restaurantId != null) {
        cartRestaurantId.value = cart.restaurantId!;
        _enrichCartItemsWithGroups();
      } else {
        cartRestaurantId.value = 0;
      }
      
      if (cart.items.isEmpty) {
        cartRestaurantId.value = 0;
        cartRestaurantName.value = '';
        cartRestaurantLogo.value = '';
        isCouponApplied.value = false;
        couponDiscount.value = 0.0;
        checkoutData.value = null;
        cookingRequest.value = '';
        isCookingRequestSaved.value = false;
      }
      
      _checkEmptyAndPop();
    }
  }

  void _checkEmptyAndPop() {
    if (items.isEmpty && Get.currentRoute == AppRoutes.cart) {
      Get.back();
      AppUtils.showSuccess('Cart is empty. Time to discover more flavors!');
    }
  }

  void _syncItemCount() {
    cartItemCount.value = quantities.values.fold(0, (sum, q) => sum + q);
  }

  Future<ApiResponse<bool>> addToCartApi(
      int menuItemId, List<int> options, int quantity, {int? restaurantId}) async {
    
    // Client-side check for different restaurant
    if (cartItemCount.value > 0 && 
        restaurantId != null && 
        cartRestaurantId.value != 0 && 
        cartRestaurantId.value != restaurantId) {
      const errorMsg = "Your cart already has items from another restaurant. Clear it before adding this dish.";
      AppUtils.showError(errorMsg);
      return const ApiResponse(success: false, message: errorMsg, data: false);
    }

    loadingItems.add(menuItemId);

    final result = await _repo.addToCart(
        menuItemId: menuItemId, options: options, quantity: quantity);
    
    if (result.success) {
      await fetchCart();
    } else {
      if (result.message.isNotEmpty) AppUtils.showError(result.message);
    }
    
    loadingItems.remove(menuItemId);
    return result;
  }

  List<CartApiModifier> getModifiersForCartItem(int cartItemId) {
    for (final item in cartApiItems) {
      if (item.id == cartItemId) return item.modifiers;
    }
    return [];
  }

  List<CartApiModifier> getModifiersForItem(int menuItemId) {
    for (final item in cartApiItems) {
      if (item.menuItemId == menuItemId) return item.modifiers;
    }
    return [];
  }

  Future<void> fetchCheckout() async {
    final result = await _repo.getCheckout();
    if (result.success && result.data != null) {
      final data = result.data!;
      checkoutData.value = data;

      if (data.isEmpty || data.items.isEmpty) {
        isCouponApplied.value = false;
        couponDiscount.value = 0.0;
        cartRestaurantId.value = 0;
        cartRestaurantName.value = '';
        cartRestaurantLogo.value = '';
        quantities.clear();
        items.clear();
        cartApiItems.clear();
        cartItemCount.value = 0;
        cookingRequest.value = '';
        isCookingRequestSaved.value = false;
        _checkEmptyAndPop();
        return;
      }

      // Populate items from checkout response
      final newQty = <int, int>{};
      final newItems = <CartItem>[];
      for (final item in data.items) {
        newQty[item.menuItemId] = (newQty[item.menuItemId] ?? 0) + item.quantity;
        newItems.add(CartItem(
          id: item.id.toString(),
          menuItemId: item.menuItemId,
          name: item.name,
          description: item.description,
          addons: item.modifiers.isNotEmpty
              ? item.modifiers.map((m) => m.optionName).join(', ')
              : null,
          price: item.unitPrice,
          basePrice: item.basePrice,
          qty: item.quantity,
          image: item.imageUrl,
          isVeg: item.isVeg,
          modifierGroups: item.modifierGroups,
        ));
      }
      quantities.value = newQty;
      items.value = newItems;
      cartApiItems.value = data.items;
      cartItemCount.value = newQty.values.fold(0, (sum, q) => sum + q);
      cartRestaurantName.value = data.restaurantName ?? cartRestaurantName.value;
      cartRestaurantLogo.value = data.restaurantLogoUrl ?? cartRestaurantLogo.value;
      if (data.restaurantId != null) {
        cartRestaurantId.value = data.restaurantId!;
        _enrichCartItemsWithGroups();
      }

      // Sync cooking request
      final instructions = data.specialInstructions;
      if (instructions == null || instructions.trim().isEmpty) {
        cookingRequest.value = '';
        isCookingRequestSaved.value = false;
      } else {
        cookingRequest.value = instructions;
        isCookingRequestSaved.value = true;
      }

      // Sync bill
      deliveryFee.value = data.bill.deliveryFee;
      taxesAndCharges.value = data.bill.taxes;
      isCouponApplied.value = data.appliedCoupon != null;
      if (data.appliedCoupon != null) {
        couponDiscount.value = data.bill.itemDiscount;
      } else {
        couponDiscount.value = 0.0;
      }
      
      _checkEmptyAndPop();
    }
  }

  Future<void> _enrichCartItemsWithGroups() async {
    if (cartRestaurantId.value == 0) return;
    try {
      final repo = RestaurantDetailRepository();
      final result = await repo.getRestaurantDetail(cartRestaurantId.value);
      if (result.success && result.data != null) {
        final allMenuItems = <int, MenuItemModel>{};
        for (var cat in result.data!.categories) {
          for (var item in cat.items) {
            allMenuItems[item.id] = item;
          }
        }
        for (var item in result.data!.recommended) {
          allMenuItems[item.id] = item;
        }

        final updatedItems = items.map((cartItem) {
          final menuItem = allMenuItems[cartItem.menuItemId];
          if (menuItem != null && cartItem.modifierGroups.isEmpty) {
            return CartItem(
              id: cartItem.id,
              menuItemId: cartItem.menuItemId,
              name: cartItem.name,
              description: cartItem.description ?? menuItem.description,
              addons: cartItem.addons,
              price: cartItem.price,
              qty: cartItem.quantity.value,
              image: cartItem.image ?? menuItem.imageUrl,
              isVeg: menuItem.isVeg,
              modifierGroups: menuItem.modifierGroups,
            );
          }
          return cartItem;
        }).toList();
        items.assignAll(updatedItems);
      }
    } catch (_) {}
  }

  double get itemTotal =>
      checkoutData.value?.bill.itemTotal ??
      items.fold(0, (sum, item) => sum + item.price * item.quantity.value);

  double get itemDiscount => checkoutData.value?.bill.itemDiscount ?? 0.0;

  double get totalToPay =>
      checkoutData.value?.bill.toPay ??
      (itemTotal + deliveryFee.value + taxesAndCharges.value -
          (isCouponApplied.value ? couponDiscount.value : 0.0));

  void addItem(String id) {
    final cartItemId = int.tryParse(id);
    if (cartItemId == null) return;
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null) {
      updateCartItemQty(cartItemId, item.quantity.value + 1,
          menuItemId: item.menuItemId, buttonType: 'plus');
    }
  }

  void decrementItem(String id) {
    final cartItemId = int.tryParse(id);
    if (cartItemId == null) return;
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null) {
      if (item.quantity.value <= 1) {
        deleteCartItem(cartItemId,
            menuItemId: item.menuItemId, buttonType: 'minus');
      } else {
        updateCartItemQty(cartItemId, item.quantity.value - 1,
            menuItemId: item.menuItemId, buttonType: 'minus');
      }
    }
  }

  Future<ApiResponse<bool>> updateCartItemApi(
      int cartItemId, List<int> options, int quantity) async {
    final loadingKey = "$cartItemId-update";
    loadingButtons.add(loadingKey);

    final result = await _repo.updateCartItemQuantity(cartItemId, quantity, options: options);
    if (result.success) {
      await fetchCart();
      await fetchCheckout();
    } else {
      if (result.message.isNotEmpty) AppUtils.showError(result.message);
      await fetchCart();
    }
    loadingButtons.remove(loadingKey);
    return result;
  }

  Future<void> updateCartItemQty(int cartItemId, int newQty,
      {int? menuItemId, String? buttonType}) async {
    final loadingKey = buttonType != null ? "$cartItemId-$buttonType" : null;

    if (loadingKey != null) loadingButtons.add(loadingKey);
    if (menuItemId != null) loadingItems.add(menuItemId);

    final result = await _repo.updateCartItemQuantity(cartItemId, newQty);
    if (result.success) {
      await fetchCart();
      await fetchCheckout();
    } else {
      // In case of error, fetch current state to ensure UI is in sync
      await fetchCart();
    }
    if (menuItemId != null) loadingItems.remove(menuItemId);
    if (loadingKey != null) loadingButtons.remove(loadingKey);
  }

  Future<void> deleteCartItem(int cartItemId,
      {int? menuItemId, String? buttonType}) async {
    final loadingKey = buttonType != null ? "$cartItemId-$buttonType" : null;

    if (loadingKey != null) loadingButtons.add(loadingKey);
    if (menuItemId != null) loadingItems.add(menuItemId);

    final result = await _repo.removeCartItem(cartItemId);
    if (result.success) {
      await fetchCart();
      await fetchCheckout();
    } else {
      await fetchCart();
    }
    if (menuItemId != null) loadingItems.remove(menuItemId);
    if (loadingKey != null) loadingButtons.remove(loadingKey);
  }

  Future<void> decrementCartItem(int menuItemId) async {
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

    if (currentQty <= 1) {
      deleteCartItem(cartItemId, menuItemId: menuItemId, buttonType: 'minus');
    } else {
      updateCartItemQty(cartItemId, currentQty - 1,
          menuItemId: menuItemId, buttonType: 'minus');
    }
  }

  void toggleCookingRequest() {
    isCookingRequestExpanded.value = !isCookingRequestExpanded.value;
    if (isCookingRequestExpanded.value) {
      cookingRequestTemp.value = cookingRequest.value;
      cookingRequestController.text = cookingRequest.value;
    }
  }

  Future<void> saveCookingRequest() async {
    final text = cookingRequestController.text.trim();
    if (text.isEmpty) {
      AppUtils.showError('Please enter valid cooking requests or cancel.');
      return;
    }

    isSavingCookingRequest.value = true;
    final result = await _repo.updateCookingRequest(text);
    isSavingCookingRequest.value = false;

    if (result.success) {
      cookingRequest.value = text;
      isCookingRequestSaved.value = true;
      isCookingRequestExpanded.value = false;
      await fetchCheckout();
    } else {
      AppUtils.showError(result.message.isNotEmpty ? result.message : 'Failed to save cooking request');
    }
  }

  void editCookingRequest() {
    isCookingRequestExpanded.value = true;
    cookingRequestTemp.value = cookingRequest.value;
    cookingRequestController.text = cookingRequest.value;
  }

  Future<void> clearCookingRequest() async {
    isSavingCookingRequest.value = true;
    final result = await _repo.updateCookingRequest('');
    isSavingCookingRequest.value = false;

    if (result.success) {
      cookingRequest.value = '';
      cookingRequestTemp.value = '';
      cookingRequestController.clear();
      isCookingRequestSaved.value = false;
      await fetchCheckout();
    }
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

    updateCartItemQty(cartItemId, currentQty + 1,
        menuItemId: menuItemId, buttonType: 'plus');
  }

  Future<void> removeFromCartApi(int menuItemId) async {
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
    deleteCartItem(cartItemId);
  }

  Future<void> clearCartApi() async {
    final result = await _repo.clearCart();
    quantities.clear();
    items.clear();
    cartApiItems.clear();
    cartItemCount.value = 0;
    cartRestaurantId.value = 0;
    cartRestaurantName.value = '';
    cartRestaurantLogo.value = '';
    isCouponApplied.value = false;
    couponDiscount.value = 0.0;
    checkoutData.value = null;
    cookingRequest.value = '';
    isCookingRequestSaved.value = false;
    if (result.success && result.message.isNotEmpty) AppUtils.showSuccess(result.message);
    
    _checkEmptyAndPop();
  }

  Future<void> applyCouponApi(int couponId) async {
    AppOverlayLoader.show();
    final result = await _repo.applyCoupon(couponId);
    AppOverlayLoader.hide();

    if (result.success) {
      await fetchCheckout();
      final coupon = checkoutData.value?.appliedCoupon;
      if (coupon != null) {
        CouponAppliedDialog.show(Get.context!, coupon, this);
      } else {
        Get.back();
      }
    } else {
      AppUtils.showError(result.message.isNotEmpty ? result.message : 'Failed to apply coupon');
    }
  }

  Future<void> removeCouponApi() async {
    AppOverlayLoader.show();
    final result = await _repo.removeCoupon();
    AppOverlayLoader.hide();

    isCouponApplied.value = false;
    couponDiscount.value = 0.0;
    if (result.success && result.message.isNotEmpty) {
      AppUtils.showSuccess(result.message);
    }
    await fetchCheckout();
  }

  Future<void> placeOrder() async {
    final addressId = checkoutData.value?.selectedAddress?.id;
    if (addressId == null) {
      AppUtils.showError('Please select a delivery address');
      return;
    }

    final id = int.tryParse(addressId);
    if (id == null) return;

    isPlacingOrder.value = true;
    AppOverlayLoader.show();
    final result = await _repo.placeOrder(id);
    AppOverlayLoader.hide();
    isPlacingOrder.value = false;

    if (result.success) {
      clearCart();
      OrderRepository.invalidateCache();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchActiveOrders();
      }
      if (Get.isRegistered<OrderHistoryController>()) {
        Get.find<OrderHistoryController>().loadOrders();
      }
      Get.offAllNamed(AppRoutes.orderSuccess);
    } else {
      AppUtils.showError(result.message.isNotEmpty ? result.message : 'Failed to place order');
    }
  }

  void applyCoupon() => isCouponApplied.value = true;
  void removeCoupon() {
    isCouponApplied.value = false;
    couponDiscount.value = 0.0;
    removeCouponApi();
  }
  void clearCart() {
    quantities.clear();
    items.clear();
    cartApiItems.clear();
    cartItemCount.value = 0;
    cartRestaurantId.value = 0;
    cartRestaurantName.value = '';
    cartRestaurantLogo.value = '';
    isCouponApplied.value = false;
    couponDiscount.value = 0.0;
    checkoutData.value = null;
    cookingRequest.value = '';
    isCookingRequestSaved.value = false;
  }
  void proceedToPlaceOrder() => Get.toNamed(AppRoutes.checkout);

  Future<void> reorderFromOrder(OrderModel order) async {
    if (order.items.isEmpty) {
      AppUtils.showError('No items found in this order to reorder.');
      return;
    }

    AppOverlayLoader.show();
    try {
      try {
        await _repo.clearCart();
      } catch (_) {}

      quantities.clear();
      items.clear();
      cartApiItems.clear();

      final rId = order.restaurantId ?? 0;
      cartRestaurantId.value = rId;
      cartRestaurantName.value = order.displayRestaurantName;
      cartRestaurantLogo.value = order.fullRestaurantImage ?? '';

      final newItems = <CartItem>[];
      for (final item in order.items) {
        final mId = int.tryParse(item.id) ?? 0;
        final qty = item.quantity > 0 ? item.quantity : 1;
        final price = item.price > 0 ? item.price : item.unitPrice;
        if (mId > 0) {
          quantities[mId] = qty;
          try {
            await _repo.addToCart(menuItemId: mId, options: const [], quantity: qty);
          } catch (_) {}
        }
        newItems.add(CartItem(
          id: item.id.isNotEmpty ? item.id : item.name,
          menuItemId: mId,
          name: item.name,
          description: '',
          addons: item.modifiers.join(', '),
          price: price,
          basePrice: price,
          qty: qty,
          image: item.image ?? order.fullRestaurantImage,
        ));
      }

      try {
        await fetchCart();
        await fetchCheckout();
      } catch (_) {}

      if (items.isEmpty && newItems.isNotEmpty) {
        items.assignAll(newItems);
        cartItemCount.value = items.fold<int>(0, (sum, i) => sum + i.quantity.value);
      }

      AppOverlayLoader.hide();
      Get.toNamed(AppRoutes.cart);
    } catch (e) {
      AppOverlayLoader.hide();
      AppUtils.showError('Failed to reorder items.');
    }
  }
}

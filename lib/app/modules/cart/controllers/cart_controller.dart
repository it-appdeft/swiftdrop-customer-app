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
  final items = <CartItem>[].obs;
  final coupons = <Coupon>[].obs;
  final RxDouble deliveryFee = 2.20.obs;
  final RxDouble taxesAndCharges = 1.20.obs;

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
    _populateDummyData();
    cookingRequestController.addListener(() {
      cookingRequestTemp.value = cookingRequestController.text;
    });
  }

  void _populateDummyData() {
    if (items.isEmpty) {
      items.addAll([
        CartItem(
          id: '1',
          name: 'Margherita Pizza Giant Slice',
          addons: 'Paneer, Olives, Jalapenos, Red Paprika, Extra Cheese, Hot & Garlic Dip, Peri Peri Dip',
          price: 8.23,
          qty: 1,
        ),
        CartItem(
          id: '2',
          name: 'Sweet Corn Pizza Regular',
          addons: 'Paneer, Olives, Jalapenos, Sweet Corns, Mozzarella Cheese, Jalapeno Dip',
          price: 8.02,
          qty: 1,
        ),
      ]);
    }

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
      // For demo purposes, add a new item if not found
      items.add(CartItem(
        id: id,
        name: 'New Pizza Item',
        price: 8.23,
        qty: 1,
      ));
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
    cookingRequest.value = cookingRequestController.text;
    isCookingRequestSaved.value = cookingRequest.value.isNotEmpty;
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

  void applyCoupon() {
    isCouponApplied.value = true;
  }

  void removeCoupon() {
    isCouponApplied.value = false;
  }

  void clearCart() => items.clear();

  void proceedToPlaceOrder() => Get.toNamed(AppRoutes.checkout);
}

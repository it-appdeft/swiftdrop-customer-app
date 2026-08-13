import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/restaurant_detail_controller.dart';
import 'product_addons_sheet.dart';

void showProductDetailBottomSheet(Map item) {
  Get.bottomSheet(
    ProductDetailContent(item: item),
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
  );
}

class ProductDetailContent extends StatefulWidget {
  final Map item;
  const ProductDetailContent({super.key, required this.item});

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent> {
  CartController? _cart;

  @override
  void initState() {
    super.initState();
    try {
      _cart = Get.find<CartController>();
    } catch (_) {}
  }

  int get _itemId => (widget.item['id'] as int?) ?? 0;

  bool get _hasModifiers {
    final groups = widget.item['modifier_groups'] as List?;
    return groups != null && groups.isNotEmpty;
  }

  Widget _buildCounter(CartController cart, int qty) {
    return Obx(() {
      final isLoading = cart.loadingItems.contains(_itemId);
      if (isLoading) {
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              AppUtils.haptic();
              cart.decrementCartItem(_itemId);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Assets.images.minus.image(width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$qty',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              AppUtils.haptic();
              if (_hasModifiers) {
                final mods = _cart?.getModifiersForItem(_itemId);
                showProductAddonsSheet(widget.item, existingModifiers: mods);
              } else {
                _cart?.incrementCartItem(_itemId);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Assets.images.plus.image(width: 24, height: 24),
            ),
          ),
        ],
      );
    });
  }

  bool _isRestaurantClosed() {
    try {
      final bool? itemIsOpen = widget.item['is_open_now'] as bool?;
      final bool? itemIsAccepting = widget.item['is_accepting_orders'] as bool?;
      if (itemIsOpen != null || itemIsAccepting != null) {
        final isOpenNow = itemIsOpen ?? true;
        final isAccepting = itemIsAccepting ?? true;
        if (!isOpenNow || !isAccepting) return true;
      }

      final info = Get.find<RestaurantDetailController>().restaurantInfo.value;
      if (info != null && (!info.isOpenNow || !info.isAcceptingOrders)) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  bool get _isItemAvailable {
    final dynamic raw = widget.item['is_available'] ?? widget.item['available'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    if (raw is String) return raw == '1' || raw.toLowerCase() == 'true';
    return true;
  }

  Widget _buildAddButton() {
    return Obx(() {
      final isLoading = _cart?.loadingItems.contains(_itemId) ?? false;
      if (isLoading) {
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          AppUtils.haptic();
          if (!_isItemAvailable) {
            AppUtils.showError("This item is currently unavailable.");
            return;
          }
          if (_isRestaurantClosed()) {
            AppUtils.showError("This restaurant is currently closed for ordering.");
            return;
          }
          if (_hasModifiers) {
            showProductAddonsSheet(widget.item);
          } else {
            try {
              int? rId = widget.item['restaurant_id'] as int?;
              if (rId == null) {
                try {
                  rId = Get.find<RestaurantDetailController>().restaurantId;
                } catch (_) {}
              }

              Get.find<CartController>().addToCartApi(_itemId, [], 1, restaurantId: rId).then((result) {
                if (result.success) {
                  Get.find<RestaurantDetailController>().showCartFloatingBar.value = true;
                }
              });
            } catch (_) {}
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            _isItemAvailable ? 'ADD' : 'UNAVAILABLE',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isItemAvailable ? AppColors.primary : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                      Icons.close, color: AppColors.iconDark, size: 24),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(
                        path: widget.item['image'] as String?,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    (widget.item['isVeg'] == false
                            ? Assets.images.nonVegToggle
                            : Assets.images.vegIcon)
                        .image(width: 16, height: 16),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item['name'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightSurfaceDarkText,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 36,
                          width: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: cart == null
                              ? _buildAddButton()
                              : Obx(() {
                                  final qty = cart.quantities[_itemId] ?? 0;
                                  return qty == 0
                                      ? _buildAddButton()
                                      : _buildCounter(cart, qty);
                                }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '£${widget.item['price']}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceLabel,
                      ),
                    ),
                    if ((widget.item['description'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        widget.item['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

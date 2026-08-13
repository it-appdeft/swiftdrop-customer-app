import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/restaurant_detail/controllers/restaurant_detail_controller.dart';
import '../modules/restaurant_detail/views/product_detail_bottom_sheet.dart';
import '../modules/restaurant_detail/views/product_addons_sheet.dart';

import '../modules/restaurant_detail/views/your_customizations_sheet.dart';

class ItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool showFavorite;
  final bool isHorizontal;
  final bool noDecoration;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  const ItemCard({
    super.key,
    required this.item,
    this.showFavorite = false,
    this.isHorizontal = true,
    this.noDecoration = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isFavourited = false;
  CartController? _cart;

  @override
  void initState() {
    super.initState();
    _isFavourited = widget.item['isFavorited'] as bool? ?? false;
    try {
      _cart = Get.find<CartController>();
    } catch (_) {}
  }

  @override
  void didUpdateWidget(ItemCard old) {
    super.didUpdateWidget(old);
    if (old.item['isFavorited'] != widget.item['isFavorited']) {
      _isFavourited = widget.item['isFavorited'] as bool? ?? false;
    }
  }

  int get _itemId => (widget.item['id'] as int?) ?? 0;

  bool get _hasModifiers {
    final groups = widget.item['modifier_groups'] as List?;
    return groups != null && groups.isNotEmpty;
  }

  Widget _buildImage(String? imageUrl) {
    return AppImage(
      path: imageUrl,
      width: widget.isHorizontal ? 128 : 154,
      height: widget.isHorizontal ? 119 : 144,
      fit: BoxFit.cover,
    );
  }

  AssetGenImage get _vegIcon =>
      widget.item['isVeg'] == false ? Assets.images.nonVegToggle : Assets.images.vegIcon;

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
                showYourCustomizationsSheet(widget.item);
              } else {
                cart.incrementCartItem(_itemId);
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

  bool _checkRestaurantConflict() {
    final cart = _cart;
    if (cart == null) return false;

    int? rId = widget.item['restaurant_id'] as int?;
    if (rId == null) {
      try {
        rId = Get.find<RestaurantDetailController>().restaurantId;
      } catch (_) {}
    }

    if (cart.cartItemCount.value > 0 &&
        rId != null &&
        cart.cartRestaurantId.value != 0 &&
        cart.cartRestaurantId.value != rId) {
      const errorMsg =
          "Your cart already has items from another restaurant. Clear it before adding this dish.";
      AppUtils.showError(errorMsg);
      return true;
    }
    return false;
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
          if (_checkRestaurantConflict()) return;

          if (_hasModifiers) {
            final cart = _cart;
            if (cart != null && (cart.quantities[_itemId] ?? 0) > 0) {
              showYourCustomizationsSheet(widget.item);
            } else {
              showProductDetailBottomSheet(widget.item);
            }
          } else {
            final cart = _cart;
            if (cart != null) {
              int? rId = widget.item['restaurant_id'] as int?;
              if (rId == null) {
                try {
                  rId = Get.find<RestaurantDetailController>().restaurantId;
                } catch (_) {}
              }

              cart.addToCartApi(_itemId, [], 1, restaurantId: rId).then((result) {
                if (result.success) {
                  try {
                    Get.find<RestaurantDetailController>().showCartFloatingBar.value = true;
                  } catch (_) {}
                }
              });
            } else {
              showProductDetailBottomSheet(widget.item);
            }
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            _isItemAvailable ? 'ADD' : 'UNAVAILABLE',
            style: GoogleFonts.inter(
              fontSize: widget.isHorizontal ? 14 : 12,
              fontWeight: widget.isHorizontal ? FontWeight.w500 : FontWeight.w600,
              color: _isItemAvailable ? AppColors.primary : AppColors.lightSurfaceSubtitle,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final isAvailable = _isItemAvailable;

    final addOrCounter = !isAvailable
        ? Container(
            height: widget.isHorizontal ? 36.h : 32.h,
            width: 112.w,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Center(
              child: Text(
                'UNAVAILABLE',
                style: GoogleFonts.inter(
                  fontSize: widget.isHorizontal ? 11.sp : 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
            ),
          )
        : Container(
            height: widget.isHorizontal ? 36.h : 32.h,
            width: 112.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: cart == null
                ? _buildAddButton()
                : Obx(() {
                    final qty = cart.quantities[_itemId] ?? 0;
                    return qty == 0 ? _buildAddButton() : _buildCounter(cart, qty);
                  }),
          );

    final imageStack = Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.isHorizontal ? 10 : 12),
          child: _buildImage(widget.item['image']),
        ),
        Positioned(
          bottom: -14,
          left: widget.isHorizontal ? 10 : 20,
          right: widget.isHorizontal ? 10 : 20,
          child: addOrCounter,
        ),
      ],
    );

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _vegIcon.image(width: 16, height: 16),
            if (widget.showFavorite)
              GestureDetector(
                onTap: () {
                  setState(() => _isFavourited = !_isFavourited);
                  widget.onFavoriteTap?.call();
                },
                behavior: HitTestBehavior.opaque,
                child: (_isFavourited ? Assets.images.favouriteAdded : Assets.images.favourite)
                    .image(width: 20, height: 20),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          widget.item['name'] ?? '',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.lightSurfaceDarkText,
            height: widget.isHorizontal ? 24 / 16 : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          '£${widget.item['price']}',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceLabel,
          ),
        ),
        SizedBox(height: 4.h),
        IntrinsicWidth(
          child: Container(
            height: 22.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: AppColors.navyMuted200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.ratingStar.image(width: 12, height: 12),
                const SizedBox(width: 4),
                Text(
                  '${widget.item['rating'] ?? '0.0'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.isHorizontal ? (widget.noDecoration ? double.infinity : 330) : null,
        height: widget.isHorizontal ? 140 : null,
        margin: widget.isHorizontal
            ? (widget.noDecoration ? EdgeInsets.zero : const EdgeInsets.only(right: 16))
            : const EdgeInsets.only(bottom: 24),
        padding: widget.isHorizontal 
            ? (widget.noDecoration ? const EdgeInsets.symmetric(horizontal: 12) : const EdgeInsets.all(12)) 
            : null,
        decoration: widget.isHorizontal && !widget.noDecoration
            ? BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12))
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageStack,
            SizedBox(width: widget.isHorizontal ? 12 : 16),
            Expanded(child: textContent),
          ],
        ),
      ),
    );
  }
}

class RestaurantWithItems extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? searchQuery;
  final bool showFavorite;
  final VoidCallback? onFavoriteTap;
  const RestaurantWithItems({
    super.key,
    required this.data,
    this.searchQuery,
    this.showFavorite = true,
    this.onFavoriteTap,
  });

  @override
  State<RestaurantWithItems> createState() => _RestaurantWithItemsState();
}

class _RestaurantWithItemsState extends State<RestaurantWithItems> {
  late bool _isFavourited;

  @override
  void initState() {
    super.initState();
    _isFavourited = widget.data['is_favorited'] ?? false;
  }

  @override
  void didUpdateWidget(covariant RestaurantWithItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data['is_favorited'] != oldWidget.data['is_favorited']) {
      setState(() {
        _isFavourited = widget.data['is_favorited'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpenNow = widget.data['is_open_now'] ?? true;
    final bool isAcceptingOrders = widget.data['is_accepting_orders'] ?? true;
    final bool isClosed = !isOpenNow || !isAcceptingOrders;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.restaurantDetail, arguments: {
            'id': widget.data['id'],
            'q': widget.searchQuery ?? '',
          }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
          color: AppColors.offWhite,
        ),
        child: Opacity(
          opacity: isClosed ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 28, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.data['name'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightSurfaceDarkText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isClosed) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'CLOSED',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Assets.images.timeIcon.image(width: 16.w, height: 16.h),
                              SizedBox(width: 4.w),
                              Text(
                                widget.data['time'] ?? '20-30 min',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightSurfaceSubtitle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(width: 1.w, height: 12.h, color: AppColors.lightSurfaceBorder),
                              SizedBox(width: 8.w),
                              Text(
                                widget.data['distance'] ?? '4.9 mi',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightSurfaceSubtitle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.showFavorite) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() => _isFavourited = !_isFavourited);
                          widget.onFavoriteTap?.call();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: (_isFavourited ? Assets.images.favouriteAdded : Assets.images.favourite)
                            .image(width: 24, height: 24),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Assets.images.rightIcon.image(width: 24, height: 24),
                  ],
                ),
              ),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  itemCount: (widget.data['items'] as List?)?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = Map<String, dynamic>.from(widget.data['items'][index]);
                    item['restaurant_id'] = widget.data['id'];
                    item['is_open_now'] = isOpenNow;
                    item['is_accepting_orders'] = isAcceptingOrders;
                    return ItemCard(item: item);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const FavoriteItemCard({
    super.key,
    required this.item,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = item['restaurant'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.offWhite, // #F6F8FA
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name']?.toString() ?? 'The Marble Grill',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Assets.images.timeIcon.image(width: 16.w, height: 16.h),
                          SizedBox(width: 4.w),
                          Text(
                            '${restaurant['time'] ?? restaurant['delivery_time'] ?? '25-35'} (min) Delivery Time',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.lightSurfaceSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(11.r),
                    border: Border.all(color: AppColors.navyMuted200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.images.ratingStar.image(width: 12, height: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant['rating'] ?? '4.8'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 33, // 16 top + 16 bottom + 1 thickness
            thickness: 1,
            color: AppColors.lightSurfaceBorder,
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ItemCard(
              item: item,
              isHorizontal: true,
              showFavorite: true,
              noDecoration: true,
              onFavoriteTap: onFavoriteTap,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

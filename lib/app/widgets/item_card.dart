import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/restaurant_detail/views/product_detail_bottom_sheet.dart';
import '../modules/restaurant_detail/views/product_addons_sheet.dart';

class ItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool showFavorite;
  final bool isHorizontal;
  final VoidCallback? onTap;
  const ItemCard({
    super.key,
    required this.item,
    this.showFavorite = false,
    this.isHorizontal = true,
    this.onTap,
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
    try {
      _cart = Get.find<CartController>();
    } catch (_) {}
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => cart.removeFromCartApi(_itemId),
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
            if (_hasModifiers) {
              final mods = _cart?.getModifiersForItem(_itemId);
              showProductAddonsSheet(widget.item, existingModifiers: mods);
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
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => showProductDetailBottomSheet(widget.item),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          'ADD',
          style: GoogleFonts.inter(
            fontSize: widget.isHorizontal ? 16 : 14,
            fontWeight: widget.isHorizontal ? FontWeight.w500 : FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;

    final addOrCounter = Container(
      height: widget.isHorizontal ? 36 : 32,
      width: 112,
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
            if (!widget.isHorizontal && widget.showFavorite)
              GestureDetector(
                onTap: () => setState(() => _isFavourited = !_isFavourited),
                behavior: HitTestBehavior.opaque,
                child: (_isFavourited ? Assets.images.favouriteAdded : Assets.images.favourite)
                    .image(width: 20, height: 20),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.item['name'] ?? '',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0B243A),
            height: widget.isHorizontal ? 24 / 16 : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '£${widget.item['price']}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF595D70),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 52,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.ratingStar.image(width: 12, height: 12),
              const SizedBox(width: 2),
              Text(
                '${widget.item['rating']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.isHorizontal ? 330 : null,
        height: 160,
        margin: widget.isHorizontal
            ? const EdgeInsets.only(right: 16)
            : const EdgeInsets.only(bottom: 24),
        padding: widget.isHorizontal ? const EdgeInsets.all(12) : null,
        decoration: widget.isHorizontal
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

class RestaurantWithItems extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? searchQuery;
  const RestaurantWithItems({super.key, required this.data, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.restaurantDetail, arguments: {
            'id': data['id'],
            'q': searchQuery ?? '',
          }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
          color: AppColors.offWhite,
        ),
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
                        Text(
                          data['name'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B243A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Assets.images.timeIcon.image(width: 16, height: 16),
                            const SizedBox(width: 4),
                            Text(
                              data['time'] ?? '20-30 min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 12, color: const Color(0xFFCFD1DC)),
                            const SizedBox(width: 8),
                            Text(
                              data['distance'] ?? '4.9 mi',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Assets.images.rightIcon.image(width: 24, height: 24),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 36),
                itemCount: (data['items'] as List?)?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = data['items'][index];
                  return ItemCard(item: item);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

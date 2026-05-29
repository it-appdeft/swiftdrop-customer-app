import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/restaurant_detail/controllers/restaurant_detail_controller.dart';

class CartFloatingBar extends StatelessWidget {
  final VoidCallback? onViewCartTap;
  final bool addSafeArea;

  const CartFloatingBar({
    super.key,
    this.onViewCartTap,
    this.addSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Obx(() {
      if (controller.items.isEmpty) return const SizedBox.shrink();

      final restaurantName = controller.cartRestaurantName.value.isNotEmpty
          ? controller.cartRestaurantName.value
          : 'Your Restaurant';
      final itemCount = controller.cartItemCount.value;

      final bar = Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AppImage(
                path: controller.cartRestaurantLogo.value.isNotEmpty
                    ? controller.cartRestaurantLogo.value
                    : null,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onViewCartTap ?? () => Get.toNamed(AppRoutes.cart),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Cart',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Assets.images.rightViewCartArrow.image(
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await controller.clearCartApi();
                try {
                  Get.find<RestaurantDetailController>()
                      .showCartFloatingBar
                      .value = false;
                } catch (_) {}
              },
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );

      if (!addSafeArea) return bar;
      return SafeArea(child: bar);
    });
  }
}

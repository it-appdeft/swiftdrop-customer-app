import 'package:swiftdrop_customer_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import 'product_addons_sheet.dart';

void showYourCustomizationsSheet(Map item) {
  Get.bottomSheet(
    YourCustomizationsContent(item: item),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class YourCustomizationsContent extends StatelessWidget {
  final Map item;
  const YourCustomizationsContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final menuItemId = (item['id'] as int?) ?? 0;

    return Obx(() {
      final cartItems = cart.cartApiItems
          .where((i) => i.menuItemId == menuItemId)
          .toList();

      if (cartItems.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isBottomSheetOpen ?? false) Get.back();
        });
        return const SizedBox.shrink();
      }

      return Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(item['name'] as String? ?? ''),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: AppColors.lightSurfaceBorder,
                    height: 32,
                  ),
                  itemBuilder: (context, index) =>
                      _buildCustomizationItem(context, cart, cartItems[index]),
                ),
              ),
              const SizedBox(height: 24),
              _buildAddNewButton(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: AppColors.iconDark, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your Customisations',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationItem(
      BuildContext context, CartController cart, CartApiItem cartItem) {
    final modifiersStr = cartItem.modifiers.isNotEmpty
        ? cartItem.modifiers.map((m) => m.optionName).join(', ')
        : 'Regular';

    final isVeg = cartItem.isVeg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (isVeg ? Assets.images.vegIcon : Assets.images.nonVegToggle)
                .image(width: 16, height: 16),
            GestureDetector(
              onTap: () {
                Get.back();
                showProductAddonsSheet(
                  item,
                  existingModifiers: cartItem.modifiers,
                  editingCartItemId: cartItem.id,
                  editingQuantity: cartItem.quantity,
                );
              },
              child: Row(
                children: [
                  Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios,
                      size: 12, color: AppColors.lightSurfaceDarkText),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modifiersStr,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '£${cartItem.unitPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantitySelector(cart, cartItem),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(CartController cart, CartApiItem cartItem) {
    final isMinusLoading =
        cart.loadingButtons.contains("${cartItem.id}-minus");
    final isPlusLoading =
        cart.loadingButtons.contains("${cartItem.id}-plus");

    return Container(
      width: 112,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isMinusLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : _buildQtyBtn(Assets.images.cartMinus, () {
                  if (cartItem.quantity <= 1) {
                    cart.deleteCartItem(cartItem.id,
                        menuItemId: cartItem.menuItemId, buttonType: 'minus');
                  } else {
                    cart.updateCartItemQty(cartItem.id, cartItem.quantity - 1,
                        menuItemId: cartItem.menuItemId, buttonType: 'minus');
                  }
                }),
          Text(
            '${cartItem.quantity}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          isPlusLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : _buildQtyBtn(Assets.images.cartPlus, () {
                  cart.updateCartItemQty(cartItem.id, cartItem.quantity + 1,
                      menuItemId: cartItem.menuItemId, buttonType: 'plus');
                }, isAdd: true),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(AssetGenImage icon, VoidCallback onTap,
      {bool isAdd = false}) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: icon.image(
        width: 32,
        height: 32,
      ),
    );
  }

  Widget _buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        Get.back();
        showProductAddonsSheet(item);
      },
      child: Text(
        'Add new customisation',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../restaurant_detail/controllers/restaurant_detail_controller.dart';
import '../../restaurant_detail/views/product_addons_sheet.dart';
import '../../restaurant_detail/views/restaurant_detail_view.dart';
import '../../restaurant_detail/views/your_customizations_sheet.dart';
import '../controllers/cart_controller.dart';
import 'repeat_last_sheet.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Spacing for sticky button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUnavailableWarning(),
            const SizedBox(height: 16),
            _buildDeliveryAddress(),
            const SizedBox(height: 16),
            _buildItemsSection(context),
            const SizedBox(height: 16),
            _buildCouponSection(),
            const SizedBox(height: 24),
            _buildBillSummary(),
            const SizedBox(height: 24),
            _buildCancellationPolicy(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomSheet: _buildPlaceOrderButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.iconDark, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Text(
            controller.checkoutData.value?.restaurantName ??
                controller.cartRestaurantName.value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          )),
    );
  }

  Widget _buildUnavailableWarning() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.alertUnavailable.image(width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some items from your previous order are unavailable. Please review your cart.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Obx(() {
      final data = controller.checkoutData.value;
      final selected = data?.selectedAddress;
      final hasAddress = selected != null;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: data == null
            ? _buildAddressShimmer()
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Assets.images.locationIcon.image(width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasAddress)
                            Text(
                              'Delivery to',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                          Text(
                            hasAddress ? selected.address : 'No address is added',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: hasAddress ? AppColors.lightSurfaceDarkText : AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.address)?.then((_) {
                          controller.fetchCheckout();
                          controller.fetchCart();
                        }),
                        child: Text(
                          hasAddress ? 'Change' : 'Add address',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildAddressShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Assets.images.locationIcon.image(width: 24, height: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.text(width: 80, height: 14),
              const SizedBox(height: 6),
              AppShimmer.text(height: 14),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppShimmer.text(width: 50, height: 14),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Items In cart',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Obx(() {
                if (controller.checkoutData.value == null) {
                  return _buildCartItemsShimmer();
                }
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.items.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 32,
                    color: AppColors.lightSurfaceBorder,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) => _buildCartItem(
                    controller.items[index],
                    isDummyUnavailable: index == 1,
                  ),
                );
              }),
              const SizedBox(height: 16),
              _buildAddAndCookingButtons(context),
              Obx(() {
                final acceptsCooking = controller.checkoutData.value?.acceptsCookingRequests ?? true;
                if (!acceptsCooking) return const SizedBox.shrink();
                return _buildCookingRequestArea();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, {bool isDummyUnavailable = false}) {
    final bool available = item.isAvailable && !isDummyUnavailable;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppImage(
            path: item.image,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
              if (!available) ...[
                const SizedBox(height: 4),
                Text(
                  'This item is currently unavailable',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ] else if (item.addons != null) ...[
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final text = item.addons ?? '';
                    final style = GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    );
                    final span = TextSpan(text: text, style: style);
                    final tp = TextPainter(
                      text: span,
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    );
                    tp.layout(maxWidth: constraints.maxWidth);
                    final bool canExpand = tp.didExceedMaxLines;

                    return Obx(() => GestureDetector(
                      onTap: canExpand ? () => item.isExpanded.toggle() : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              text,
                              style: style,
                              maxLines: item.isExpanded.value ? null : 1,
                              overflow: item.isExpanded.value ? null : TextOverflow.ellipsis,
                            ),
                          ),
                          if (canExpand)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Transform.rotate(
                                angle: item.isExpanded.value ? 3.14159 : 0,
                                child: Assets.images.locationdropIcon.image(
                                  width: 16,
                                  height: 16,
                                  color: AppColors.lightSurfaceSubtitle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ));
                  },
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (available)
                    Text(
                      '£${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceLabel,
                      ),
                    ),
                  if (available)
                    _buildQuantitySelector(item)
                  else
                    _buildRemoveButton(item),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(CartItem item) {
    return GestureDetector(
      onTap: () => controller.deleteCartItem(int.parse(item.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFE9E5)),
        ),
        child: Text(
          'Remove',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(CartItem item) {
    return Obx(() {
      final isPlusLoading = controller.loadingButtons.contains("${item.id}-plus");
      final isMinusLoading = controller.loadingButtons.contains("${item.id}-minus");
      
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
            _buildQtyBtn(
              Assets.images.cartMinus,
              () => controller.decrementItem(item.id),
              isLoading: isMinusLoading,
            ),
            Text(
              '${item.quantity.value}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            _buildQtyBtn(
              Assets.images.cartPlus,
              () {
                if (item.hasModifiers) {
                  showRepeatLastSheet(
                    item.toMap(restaurantId: controller.cartRestaurantId.value),
                    onRepeat: () => controller.addItem(item.id),
                  );
                } else {
                  controller.addItem(item.id);
                }
              },
              isAdd: true,
              isLoading: isPlusLoading,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQtyBtn(AssetGenImage icon, VoidCallback onTap,
      {bool isAdd = false, bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(0),
        child: isLoading
            ? const SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            : icon.image(
                width: 32,
                height: 32,
              ),
      ),
    );
  }

  Widget _buildAddAndCookingButtons(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isCookingRequestExpanded.value;
      final isSaved = controller.isCookingRequestSaved.value;
      final isSelected = isExpanded || isSaved;
      final showCross = isSaved && !isExpanded;
      final cookingWidth = showCross ? 190.0 : 166.0;
      final acceptsCooking = controller.checkoutData.value?.acceptsCookingRequests ?? true;

      return Row(
        children: [
          GestureDetector(
            onTap: () => _openAddItems(context),
            child: Container(
              width: 112,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightSurfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.lightSurfaceSubtitle, size: 20),
                  const SizedBox(width: 3),
                  Text(
                    'Add Items',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (acceptsCooking) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: controller.toggleCookingRequest,
            child: Container(
              width: cookingWidth,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? null : Border.all(color: AppColors.lightSurfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (isSelected ? Assets.images.cookingSelected : Assets.images.cookingUnselected)
                      .image(
                    width: 20,
                    height: 20,
                    color: isSelected ? AppColors.white : AppColors.lightSurfaceDarkText,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'Cooking Requests',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? AppColors.white : AppColors.lightSurfaceDarkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showCross) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        controller.clearCookingRequest();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.close, color: AppColors.white, size: 20),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ],
        ],
      );
    });
  }

  Widget _buildCookingRequestArea() {
    if (controller.isCookingRequestExpanded.value) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.cookingRequestController,
                      maxLength: 300,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type cooking requests',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        counterText: "",
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Obx(() {
                    final canSave = controller.cookingRequestTemp.value.trim().isNotEmpty;
                    final isSaving = controller.isSavingCookingRequest.value;
                    return GestureDetector(
                      onTap: (canSave && !isSaving) ? controller.saveCookingRequest : null,
                      child: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              'Save',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: canSave ? AppColors.primary : AppColors.lightSurfaceDisabled,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Obx(() => Text(
                      '${controller.cookingRequestTemp.value.length}/300',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    )),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.lightOtpBoxBg, // #EDEEF1 for disclaimer
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                'The restaurant will do its best to accommodate your request. However, refunds cannot be issued for unmet special requests.',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.navyMuted600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (controller.isCookingRequestSaved.value) {
      return Container(
        margin: const EdgeInsets.only(top: 16,left:4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.cookingRequest.value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.editCookingRequest,
              child: Assets.images.cookingUnselected.image(
                width: 18,
                height: 18,
                color: AppColors.iconDark,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCouponSection() {
    return Obx(() {
      final applied = controller.checkoutData.value?.appliedCoupon;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.coupons),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.images.couponIcon.image(width: 20, height: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      applied != null
                          ? '${applied.headline} ${applied.code}'
                          : 'View all coupons',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                  ],
                ),
              ),
              Assets.images.rightArrow.image(width: 24, height: 24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBillSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bill Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(top: 24,bottom: 16,left: 12,right: 12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() {
                if (controller.checkoutData.value == null) {
                  return _buildBillShimmer();
                }
                return Column(
                  children: [
                    _buildBillRow('Item Total', '£${controller.itemTotal.toStringAsFixed(2)}'),
                    if (controller.itemDiscount > 0) ...[
                      const SizedBox(height: 8),
                      _buildBillRow('Item Discount', '-£${controller.itemDiscount.toStringAsFixed(2)}', isDiscount: true),
                    ],
                    const SizedBox(height: 8),
                    _buildBillRow('Delivery Fee', '£${controller.deliveryFee.value.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildBillRow('Taxes & Charges', '£${controller.taxesAndCharges.value.toStringAsFixed(2)}'),
                    const Divider(height: 32, color: AppColors.lightSurfaceBorder, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To Pay',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                        ),
                        Text(
                          '£${controller.totalToPay.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceCusinsSubtitle,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDiscount ? AppColors.primary : AppColors.lightSurfaceDarkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation policy',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please double-check your orders and address details. Orders are not-refundable once placed.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceSubtitle,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsShimmer() {
    return Column(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0)
            const Divider(height: 32, color: AppColors.lightSurfaceBorder, thickness: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.rect(width: 96, height: 96, radius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.text(height: 16),
                    const SizedBox(height: 8),
                    AppShimmer.text(width: 140, height: 14),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppShimmer.text(width: 60, height: 16),
                        AppShimmer.rect(width: 112, height: 40, radius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBillShimmer() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer.text(width: 80, height: 14),
              AppShimmer.text(width: 50, height: 14),
            ],
          ),
        ],
        const Divider(height: 32, color: AppColors.lightSurfaceBorder, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppShimmer.text(width: 50, height: 16),
            AppShimmer.text(width: 70, height: 16),
          ],
        ),
      ],
    );
  }

  void _openAddItems(BuildContext context) {
    if (Get.previousRoute == AppRoutes.restaurantDetail) {
      Get.back();
      return;
    }

    final restaurantId = controller.cartRestaurantId.value;
    if (restaurantId == 0) return;

    if (!Get.isRegistered<RestaurantDetailRepository>()) {
      Get.put(RestaurantDetailRepository());
    }
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.put(FavoritesRepository());
    }

    Get.delete<RestaurantDetailController>(force: true);
    Get.put(RestaurantDetailController(
      Get.find<RestaurantDetailRepository>(),
      Get.find<FavoritesRepository>(),
      restaurantId,
    ));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.92,
              child: const RestaurantDetailView(isSheet: true),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CartFloatingBar(
              onViewCartTap: () => Navigator.of(ctx, rootNavigator: true).pop(),
            ),
          ),
        ],
      ),
    ).then((_) {
      Get.delete<RestaurantDetailController>(force: true);
      controller.fetchCheckout();
    });
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).padding.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppButton(
          label: 'Place Order',
          onTap: () {
            controller.placeOrder();
          },
        ),
      ),
    );
  }
}

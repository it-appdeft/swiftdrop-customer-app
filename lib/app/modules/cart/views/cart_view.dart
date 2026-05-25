import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/cart_controller.dart';

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
            _buildDeliveryAddress(),
            const SizedBox(height: 24),
            _buildItemsSection(),
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
      title: Text(
        'The Marble Grill',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.lightSurfaceDarkText,
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
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
                  Text(
                    'Delivery to',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                  Text(
                    '221B Baker St, London, UK',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceDarkText,
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
                onTap: () {},
                child: Text(
                  'Change',
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
  }

  Widget _buildItemsSection() {
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
              Obx(() => ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.items.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 32,
                      color: AppColors.lightSurfaceBorder,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) => _buildCartItem(controller.items[index]),
                  )),
              const SizedBox(height: 16),
              _buildAddAndCookingButtons(),
              Obx(() => _buildCookingRequestArea()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Assets.images.onbording1.image(
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
              if (item.addons != null) ...[
                const SizedBox(height: 4),
                Obx(() => GestureDetector(
                  onTap: () => item.isExpanded.toggle(),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'Paneer, Olives, Jalapenos, Red Paprika, Extra Cheese, Hot & Garlic Dip, Peri Peri Dip',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                          maxLines: item.isExpanded.value ? null : 1,
                          overflow: item.isExpanded.value ? null : TextOverflow.ellipsis,
                        ),
                      ),
                     // const SizedBox(width: 4),
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
                )),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '£${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceLabel,
                    ),
                  ),
                  _buildQuantitySelector(item),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(CartItem item) {
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
          _buildQtyBtn(Assets.images.cartMinus, () => controller.decrementItem(item.id)),
          Obx(() => Text(
                '${item.quantity.value}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSurfaceDarkText,
                ),
              )),
          _buildQtyBtn(Assets.images.cartPlus, () => controller.addItem(item.id), isAdd: true),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(AssetGenImage icon, VoidCallback onTap, {bool isAdd = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(0),
        child: icon.image(
          width: 32,
          height: 32,
        ),
      ),
    );
  }

  Widget _buildAddAndCookingButtons() {
    return Obx(() {
      final isExpanded = controller.isCookingRequestExpanded.value;
      final isSaved = controller.isCookingRequestSaved.value;
      final isSelected = isExpanded || isSaved;
      final showCross = isSaved && !isExpanded;
      final cookingWidth = showCross ? 190.0 : 166.0;

      return Row(
        children: [
          GestureDetector(
            onTap: () {},
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
                  GestureDetector(
                    onTap: controller.saveCookingRequest,
                    child: Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
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
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
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
                        controller.isCouponApplied.value
                            ? '£12.00 Saved EXCLUSIVE WELCOME'
                            : 'View all coupons',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                      ),
                      if (controller.isCouponApplied.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'View all coupons',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.lightSurfaceSubtitle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Assets.images.rightArrow.image(width: 24, height: 24),
              ],
            ),
          ),
        ));
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
          child: Obx(() => Column(

                children: [
                  _buildBillRow('Item Total', '£${controller.itemTotal.toStringAsFixed(2)}'),

                  // if (controller.isCouponApplied.value)
                  //   _buildBillRow('Item Discount', '-£${controller.couponDiscount.value.toStringAsFixed(2)}', isDiscount: true),
                  const SizedBox(height: 8),
                  _buildBillRow('Delivery Fee', '£${controller.deliveryFee.value.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildBillRow('Taxes & Charges', '£${controller.taxesAndCharges.value.toStringAsFixed(2)}'),
                  const Divider(height: 32, color: AppColors.lightSurfaceBorder,thickness: 1,),
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
              )),
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
            controller.clearCart();
            Get.toNamed(AppRoutes.orderSuccess);
          },
        ),
      ),
    );
  }
}

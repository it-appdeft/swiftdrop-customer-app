import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/address_controller.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 11),
            _buildSearchRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionButtons(context),
                    const SizedBox(height: AppDimensions.gapXl),
                    Text(
                      'Saved Addresses',
                      style: AppTextStyles.pLarge.copyWith(
                        color: AppColors.lightSurfaceDarkText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapLg),
                    _buildAddressList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Assets.images.back.image(width: 24, height: 24),
                ),
              ),
            ),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightSurfaceBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Assets.images.homeSearchIcon.image(width: 24, height: 24),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: controller.queryController,
                      cursorColor: AppColors.iconDark,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Search address, area, landmark..',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.my_location,
            label: 'Use Current Location',
            onTap: () async {
              final canGoBack = Navigator.canPop(context);
              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
              }
              if (permission == LocationPermission.deniedForever) {
                AppUtils.showLocationPermissionDialog();
                return;
              }
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                if (canGoBack) {
                  Get.until((route) => route.settings.name == AppRoutes.dashboard);
                } else {
                  Get.offAllNamed(AppRoutes.dashboard);
                }
              }
            },
          ),
        ),
        const SizedBox(width: AppDimensions.gapMd),
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add New Address',
            onTap: () => Get.toNamed(AppRoutes.deliveryAddress),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.pSmallMedium.copyWith(
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Obx(() {
        final addresses = controller.displayedAddresses;
        return Column(
          children: [
            ...addresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              return Column(
                children: [
                  _buildAddressTile(context, address),
                  if (index < addresses.length - 1 || !controller.showAll.value)
                    const Divider(
                      height: 1.5,
                      color: AppColors.lightSurfaceBorder,
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }),
            if (!controller.showAll.value)
              Center(
                child: TextButton(
                  onPressed: controller.toggleViewAll,
                  child: Text(
                    'View all',
                    style: AppTextStyles.pSmallSemiBold.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppDimensions.paddingXs),
          ],
        );
      }),
    );
  }

  Widget _buildAddressTile(BuildContext context, AddressModel address) {
    return InkWell(
      onTap: () {
        controller.selectAddress(address.id);
        if (Navigator.canPop(context)) {
          Get.until((route) => route.settings.name == AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                controller.selectAddress(address.id);
                if (Navigator.canPop(context)) {
                  Get.until((route) => route.settings.name == AppRoutes.dashboard);
                } else {
                  Get.offAllNamed(AppRoutes.dashboard);
                }
              },
              child: SizedBox(
                height: 20,
                width: 20,
                child: address.isSelected
                    ? Assets.images.addressSelected.image(width: 20, height: 20)
                    : Assets.images.addressUnselected.image(width: 20, height: 20),
              ),
            ),
            const SizedBox(width: AppDimensions.gapXl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.pMedium.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.address,
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showAddressOptions(address),
              icon: const Icon(Icons.more_vert, color: AppColors.lightSurfaceSubtitle),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressOptions(AddressModel address) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Address', style: AppTextStyles.pMedium.copyWith(color: AppColors.error)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(address);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(AddressModel address) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSm)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //const SizedBox(height: AppDimensions.gapSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Are you sure you want to delete this address?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,

                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapSm),
                  Text(
                    '${address.label} ${address.address}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.navyMuted500,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.gapXl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Yes',
                    onTap: () {
                      controller.deleteAddress(address.id);
                      Get.back();
                    },
                    backgroundColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
                const SizedBox(width: AppDimensions.gapMd),
                Expanded(
                  child: AppButton(
                    label: 'No',
                    onTap: () => Get.back(),
                    backgroundColor: AppColors.greyButton,
                    textColor: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSm),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

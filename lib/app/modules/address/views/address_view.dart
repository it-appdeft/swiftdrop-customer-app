import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/address_controller.dart';
import '../controllers/delivery_address_controller.dart' show PlacePrediction;

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
              child: Obx(() {
                if (controller.isSearchActive.value) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: _buildSearchResultsContent(),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
                        ],
                      ),
                    ),
                    Expanded(child: _buildAddressList()),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    final permissionDenied =
        Get.arguments is Map && (Get.arguments as Map)['permissionDenied'] == true;
    final canPop = !permissionDenied && (Get.key.currentState?.canPop() ?? false);
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
                      focusNode: controller.searchFocusNode,
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
                  Obx(() => controller.isSearchActive.value
                      ? GestureDetector(
                          onTap: controller.clearSearch,
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(
                            Icons.clear,
                            color: AppColors.lightSurfaceSubtitle,
                            size: 20,
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsContent() {
    return Obx(() {
      if (controller.isSearchingPlaces.value && controller.placeSuggestions.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 8),
          child: _ShimmerAddressTiles(),
        );
      }
      if (controller.placeSuggestions.isEmpty) {
        if (controller.queryController.text.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No results found',
            style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceSubtitle),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: controller.placeSuggestions.length,
        itemBuilder: (_, i) => _buildSuggestionTile(controller.placeSuggestions[i]),
      );
    });
  }

  Widget _buildSuggestionTile(PlacePrediction place) {
    return InkWell(
      onTap: () => controller.selectPlace(place),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Assets.images.locationIcon.image(width: 20, height: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.mainText,
                    style: AppTextStyles.pMedium.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (place.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      place.secondaryText,
                      style: AppTextStyles.pXSmall.copyWith(
                        color: AppColors.lightSurfaceSubtitle,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
              }
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                AppOverlayLoader.show();
                try {
                  final position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.medium,
                  );
                  controller.startAdd();
                  // Hide BEFORE navigating — hide() calls Get.back() which would
                  // pop the map-picker if called after Get.toNamed().
                  AppOverlayLoader.hide();
                  Get.toNamed(AppRoutes.mapPicker, arguments: {
                    'lat': position.latitude,
                    'lng': position.longitude,
                  });
                } catch (_) {
                  AppOverlayLoader.hide();
                  AppUtils.showError('Unable to get GPS location. Please try again.');
                }
              } else {
                AppUtils.showLocationPermissionDialog();
              }
            },
          ),
        ),
        const SizedBox(width: AppDimensions.gapMd),
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add New Address',
            onTap: () {
              controller.startAdd();
              Get.toNamed(AppRoutes.mapPicker);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
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

  Widget _buildAddressList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _ShimmerAddressTiles(),
        );
      }
      if (controller.savedAddresses.isEmpty) {
        return Center(
          child: NoDataWidget(
            image: Assets.images.noAddress.image(width: 96, height: 96),
            title: 'No Address Available',
            subtitle: 'We couldn\'t find an address. Please add or select Current location to add address.',
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.lightSurfaceBorder),
        ),
        child: Column(
          children: [
            ...controller.savedAddresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              return Column(
                children: [
                  _buildAddressTile(address),
                  if (index < controller.savedAddresses.length - 1)
                    const Divider(
                      height: 1.5,
                      color: AppColors.lightSurfaceBorder,
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }),
            if (controller.hasMore.value || controller.isLoadingMore.value)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: controller.isLoadingMore.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : TextButton(
                        onPressed: controller.loadMore,
                        child: Text(
                          'Load more',
                          style: AppTextStyles.pSmallSemiBold.copyWith(
                            color: AppColors.lightSurfaceDarkText,
                          ),
                        ),
                      ),
              ),
            const SizedBox(height: AppDimensions.paddingXs),
          ],
        ),
      ));
    });
  }

  Widget _buildAddressTile(AddressModel address) {
    return InkWell(
      onTap: () => controller.selectAddress(address.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => controller.selectAddress(address.id),
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
              leading: const Icon(Icons.edit_outlined, color: AppColors.lightSurfaceDarkText),
              title: Text('Edit Address',
                  style: AppTextStyles.pMedium.copyWith(color: AppColors.lightSurfaceDarkText)),
              onTap: () {
                Get.back();
                controller.startEdit(address);
                Get.toNamed(AppRoutes.mapPicker, arguments: {
                  'lat': address.lat,
                  'lng': address.lng,
                  'name': address.addressLine1,
                  'address': address.address,
                  'city': address.city,
                  'county': address.county,
                });
              },
            ),
            const Divider(height: 1, color: AppColors.lightSurfaceBorder),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Address',
                  style: AppTextStyles.pMedium.copyWith(color: AppColors.error)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSm)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    onTap: () async {
                      Get.back();
                      await controller.deleteAddress(address.id);
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

class _ShimmerAddressTiles extends StatelessWidget {
  const _ShimmerAddressTiles();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLg,
                vertical: AppDimensions.paddingMd,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppShimmer.rect(width: 20, height: 20, radius: AppDimensions.radiusXs),
                  const SizedBox(width: AppDimensions.gapXl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.text(height: 14),
                        const SizedBox(height: 4),
                        AppShimmer.text(width: 160, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.gapSm),
                  AppShimmer.rect(width: 20, height: 20, radius: AppDimensions.radiusXs),
                ],
              ),
            ),
            if (i < 2)
              const Divider(
                height: 1.5,
                color: AppColors.lightSurfaceBorder,
                indent: 20,
                endIndent: 20,
              ),
          ],
        ],
      ),
    );
  }
}

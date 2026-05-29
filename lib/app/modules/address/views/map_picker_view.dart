import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class MapPickerView extends GetView<MapPickerController> {
  const MapPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            final showMap = !controller.isCheckingPermission.value &&
                (!controller.isPermissionDenied.value ||
                    controller.hasManualLocation.value);
            if (!showMap) return Container(color: Colors.white);
            final locationAllowed = !controller.isPermissionDenied.value;
            return GoogleMap(
              initialCameraPosition: controller.initialCameraPosition,
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
              myLocationEnabled: locationAllowed,
              myLocationButtonEnabled: locationAllowed,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            );
          }),
          // Fixed centre pin — tip aligned to map centre
          Obx(() {
            final showPin = !controller.isCheckingPermission.value &&
                (!controller.isPermissionDenied.value ||
                    controller.hasManualLocation.value);
            if (!showPin) return const SizedBox.shrink();
            return const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, color: AppColors.primary, size: 48),
              ),
            );
          }),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 11),
                _buildSearchBar(),
                const Spacer(),
                _buildDeliveryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Assets.images.back.image(width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await Get.toNamed(
                  AppRoutes.deliveryAddress,
                  arguments: {'fromMapPicker': true},
                );
                if (result != null && result is Map) {
                  controller.setLocationFromSearch(Map<String, dynamic>.from(result));
                }
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Assets.images.homeSearchIcon.image(width: 24, height: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Search address, area, landmark..',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Order will be delivered here',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Assets.images.locationIcon.image(width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLocationText()),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Confirm & Proceed',
                  onTap: () => Get.toNamed(
                    AppRoutes.addressDetails,
                    arguments: {
                      'address_line_1': controller.locationName.value,
                      'city': controller.locationCity.value,
                      'county': controller.locationCounty.value,
                      'postcode': controller.locationPostcode.value,
                      'lat': controller.currentLat,
                      'lng': controller.currentLng,
                    },
                  ),
                  backgroundColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  height: 56,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationText() {
    return Obx(() {
      if (controller.isGeocoding.value) {
        return const SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }

      final name = controller.locationName.value;
      final address = controller.locationAddress.value;

      if (name.isEmpty) {
        return Text(
          'Move the map to select location',
          style: AppTextStyles.pMedium.copyWith(color: AppColors.lightSurfaceSubtitle),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Helvetica Neue',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.2,
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceSubtitle,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      );
    });
  }
}

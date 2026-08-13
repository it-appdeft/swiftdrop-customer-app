import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class MapPickerView extends GetView<MapPickerController> {
  const MapPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
              myLocationButtonEnabled: false, // We use custom floating button
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
            return Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildSearchBar(),
                const Spacer(),
                _buildMyLocationButton(),
                const SizedBox(height: 12),
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
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Assets.images.back.image(width: 20, height: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Assets.images.homeSearchIcon.image(width: 20, height: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search address, area, landmark...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildMyLocationButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            AppUtils.haptic();
            controller.recenterMap();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.orderDeliveredHere,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Assets.images.locationIcon.image(width: 20, height: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLocationText()),
                  ],
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: AppStrings.confirmAndProceed,
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
                  height: 52,
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

      if (name.isEmpty) return const SizedBox(height: 24);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              address,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    });
  }
}

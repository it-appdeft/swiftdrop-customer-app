import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/delivery_address_controller.dart';

class DeliveryAddressView extends GetView<DeliveryAddressController> {
  const DeliveryAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isForced =
        Get.arguments is Map && (Get.arguments as Map)['forceRedirect'] == true;
    final bool fromMapPicker =
        Get.arguments is Map && (Get.arguments as Map)['fromMapPicker'] == true;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: isForced
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
                onPressed: () => Get.back(),
              ),
        title: Text(
          'Search Location',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.query.value.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentLocationOption(fromMapPicker),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
                    ),
                  ],
                );
              }
              if (controller.isSearching.value && controller.suggestions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.suggestions.isEmpty) {
                return Center(
                  child: Text(
                    'No results found',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  _buildCurrentLocationOption(fromMapPicker),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
                  ),
                  Expanded(child: _buildSuggestionsList()),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Assets.images.homeSearchIcon.image(width: 20, height: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              autofocus: true,
              cursorColor: AppColors.primary,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: 'Search address, area, landmark...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
            ),
          ),
          Obx(() => controller.query.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearQuery,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: AppColors.lightSurfaceSubtitle, size: 14),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationOption(bool fromMapPicker) {
    return InkWell(
      onTap: () async {
        AppUtils.haptic();
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          if (fromMapPicker) {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            Get.back(result: {
              'name': AppStrings.currentLocation,
              'address': AppStrings.usingDeviceGps,
              'lat': pos.latitude,
              'lng': pos.longitude,
            });
          } else {
            Get.toNamed(AppRoutes.mapPicker, arguments: {'useCurrentLocation': true});
          }
        } else {
          Get.toNamed(AppRoutes.address);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Assets.images.currentLocation.image(width: 20, height: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.useCurrentLocation,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.usingDeviceGps,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.lightSurfaceSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: controller.suggestions.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final place = controller.suggestions[index];
        return InkWell(
          onTap: () => controller.selectPlace(place),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Assets.images.locationIcon.image(width: 18, height: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.mainText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                      ),
                      if (place.secondaryText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          place.secondaryText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightSurfaceSubtitle,
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
      },
    );
  }
}

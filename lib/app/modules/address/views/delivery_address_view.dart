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
        leading: isForced
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20),
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
          ),
          Expanded(
            child: Obx(() {
              // if (controller.query.value.isEmpty) {
              //   return _buildCurrentLocationOption(fromMapPicker);
              // }
              if (controller.isSearching.value && controller.suggestions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.suggestions.isEmpty) {
                return Center(
                  child: Text(
                    'No results found',
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                );
              }
              return _buildSuggestionsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Assets.images.homeSearchIcon.image(width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              autofocus: true,
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
          Obx(() => controller.query.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearQuery,
                  child: const Icon(Icons.clear, color: AppColors.lightSurfaceSubtitle, size: 20),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationOption(bool fromMapPicker) {
    return InkWell(
      onTap: () async {
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
              'name': 'Current Location',
              'address': 'Your current location',
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Assets.images.currentLocation.image(width: 24, height: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current location',
                  style: AppTextStyles.pMedium.copyWith(
                    color: AppColors.lightSurfaceDarkText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   'Using device GPS',
                //   style: GoogleFonts.inter(
                //     fontSize: 10,
                //     fontWeight: FontWeight.w400,
                //     color: AppColors.lightSurfaceSubtitle,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: controller.suggestions.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final place = controller.suggestions[index];
        return InkWell(
          onTap: () => controller.selectPlace(place),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
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
      },
    );
  }
}

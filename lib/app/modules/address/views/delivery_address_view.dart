import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/delivery_address_controller.dart';

class DeliveryAddressView extends GetView<DeliveryAddressController> {
  const DeliveryAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if user can go back. If permission was denied, they are redirected
    // here with Get.offAllNamed, so Navigator.canPop will be false.
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          'Delivery Address',
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
          _buildChooseOnMap(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
          ),
          Expanded(
            child: Obx(() {
              if (controller.query.value.isEmpty) {
                return _buildInitialState();
              } else {
                return _buildSuggestionsList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
             // color: AppColors.offWhite,
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
                    controller: controller.searchController,
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
                      hintText: 'Enter a new address',
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
    );
  }

  Widget _buildChooseOnMap() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.mapPicker),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Row(
          children: [
            Assets.images.chooseOnMap.image(width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              'Choose on map',
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return InkWell(
      onTap: () async {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.deniedForever) {
          _showSettingsDialog();
          return;
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Get.offAllNamed(AppRoutes.dashboard);
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
                const SizedBox(height: 4),
                Text(
                  'Allow location permissions',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_suggest_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Permission Required',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Location permission is permanently denied. Please enable it in your device settings to use your current location.',
                textAlign: TextAlign.center,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Open Settings',
                onTap: () {
                  Get.back();
                  Geolocator.openAppSettings();
                },
                backgroundColor: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.pSmallMedium.copyWith(
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: controller.suggestions.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final suggestion = controller.suggestions[index];
        return InkWell(
          onTap: () => _showConfirmLocationDialog(suggestion),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Assets.images.locationIcon.image(width: 24, height: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion['title']!,
                            style: AppTextStyles.pSmallMedium.copyWith(
                              color: AppColors.lightSurfaceDarkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            suggestion['subtitle']!,
                            style: AppTextStyles.pXSmall.copyWith(
                              color: AppColors.lightSurfaceSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // if (index < controller.suggestions.length - 1)
              //   const Divider(height: 1, color: AppColors.lightSurfaceBorder, indent: 52),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmLocationDialog(Map<String, String> suggestion) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Assets.images.mainIcon.image(width: 80, height: 80),
             // const SizedBox(height: 16),
              const Text(
                'Confirm Location',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20, // H6 size
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The selected location is quite far from your current location. This may affect available services or delivery. Do you want to continue with this location?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11, // Pxs size
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,

                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Select Another Location',
                onTap: () => Get.back(),
                backgroundColor: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                height: 52,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.mapPicker);
                },
                child: Text(
                  'Continue Anyway',
                  style: AppTextStyles.pSmallMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

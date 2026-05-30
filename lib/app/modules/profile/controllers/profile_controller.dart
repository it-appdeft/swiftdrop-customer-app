import 'package:swiftdrop_customer_app/export.dart';

class ProfileController extends BaseController {
  final ProfileRepository _profileRepo;
  ProfileController(this._profileRepo);

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = AuthService.to.currentUser.value;
    ever(AuthService.to.currentUser, (u) => user.value = u);
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final result = await _profileRepo.getProfile();
    if (result.success && result.data != null) {
      await AuthService.to.saveSession(
        accessToken: StorageService.to.read<String>(StorageKeys.authToken) ??
            AppConfig.accessTokenKey,
        user: result.data!.user,
      );
      await AuthService.to.saveSelectedAddress(result.data!.selectedAddress);
    }
  }

  Future<void> _performLogout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await AuthService.to.logout();
      Get.back(); // dismiss the bottom sheet only after the API resolves
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoggingOut.value = false;
    }
  }

  void logout() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.topXl,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMd,
              AppDimensions.paddingLg,
              AppDimensions.paddingMd,
              AppDimensions.paddingMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are You Sure You Want To\nLog Out?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.lightSurfaceDarkText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.gapMd),
                Text(
                  'You will be signed out of your account and will need to log in again to access your dashboard.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pSmall.copyWith(
                    color: AppColors.lightSurfaceSubtitle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.gapXl),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => AppButton(
                            label: 'Yes',
                            onTap: isLoggingOut.value ? null : _performLogout,
                            isLoading: isLoggingOut.value,
                            borderRadius: AppRadius.sm,
                          )),
                    ),
                    const SizedBox(width: AppDimensions.gapMd),
                    Expanded(
                      child: Obx(() => AppButton(
                            label: 'No',
                            onTap:
                                isLoggingOut.value ? null : Get.back,
                            backgroundColor: AppColors.lightSurfaceSubtitle,
                            borderRadius: AppRadius.sm,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  void navigateToSettings() => Get.toNamed(AppRoutes.settings);
  void navigateToEditProfile() => Get.toNamed(AppRoutes.editProfile);
}

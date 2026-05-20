import 'dart:io';

import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: AppDimensions.iconSm,
            color: AppColors.lightSurfaceText,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceHeading),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileAvatar(),
                    const SizedBox(height: AppDimensions.gapXl),
                    _FieldLabel(label: 'Full Name'),
                    const SizedBox(height: AppDimensions.gapSm),
                    _NameField(),
                    const SizedBox(height: AppDimensions.gapLg),
                    _FieldLabel(label: 'Mobile Number'),
                    const SizedBox(height: AppDimensions.gapSm),
                    _PhoneRow(),
                    const SizedBox(height: AppDimensions.gapLg),
                    _FieldLabel(label: 'Email Address'),
                    const SizedBox(height: AppDimensions.gapSm),
                    _EmailRow(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.paddingMd,
                right: AppDimensions.paddingMd,
                bottom: bottomPadding + AppDimensions.paddingLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DeleteAccountRow(),
                  const SizedBox(height: AppDimensions.gapMd),
                  Obx(() => AppButton(
                        label: 'Save',
                        onTap: controller.isProfileDirty
                            ? () {
                                FocusScope.of(context).unfocus();
                                controller.saveProfile();
                              }
                            : null,
                        isLoading: controller.isLoading.value,
                        borderRadius: AppRadius.sm,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.pSmallMedium.copyWith(
        color: AppColors.lightSurfaceLabel,
      ),
    );
  }
}

class _ProfileAvatar extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppDimensions.avatarXl,
        height: AppDimensions.avatarXl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: AppDimensions.avatarXl,
              height: AppDimensions.avatarXl,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightSurfaceBorder,
              ),
              child: ClipOval(
                child: Obx(() {
                  final picked = controller.selectedAvatarPath.value;
                  if (picked != null && picked.isNotEmpty) {
                    return Image.file(
                      File(picked),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _initialFallback(),
                    );
                  }
                  final avatar = controller.currentUser.value?.avatar;
                  if (avatar != null && avatar.isNotEmpty) {
                    return Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _initialFallback(),
                    );
                  }
                  return _initialFallback();
                }),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showImageSourceSheet(context),
                child: Container(
                  width: AppDimensions.iconLg,
                  height: AppDimensions.iconLg,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: AppDimensions.iconSm,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialFallback() {
    final name = controller.currentUser.value?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.h3.copyWith(color: AppColors.lightSurfaceText),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.topXl,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.gapMd),
              Container(
                width: AppDimensions.iconLg,
                height: AppDimensions.gapXs,
                decoration: BoxDecoration(
                  color: AppColors.lightSurfaceBorder,
                  borderRadius: AppRadius.full,
                ),
              ),
              const SizedBox(height: AppDimensions.gapMd),
              _ImageSourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take photo',
                onTap: () {
                  Get.back();
                  controller.pickAvatarFromCamera();
                },
              ),
              _ImageSourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () {
                  Get.back();
                  controller.pickAvatarFromGallery();
                },
              ),
              const SizedBox(height: AppDimensions.gapMd),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: AppTextStyles.pMedium.copyWith(color: AppColors.lightSurfaceText),
      ),
      onTap: onTap,
    );
  }
}

class _NameField extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceText,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.transparent,
                hintText: 'Enter Your Full Name',
                hintStyle: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSm,
                ),
              ),
            ),
          ),
        ],
       ),
    );
  }
}

class _PhoneRow extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => AppPhoneField(
          controller: controller.displayPhoneController,
          countryFlag: '🇬🇧',
          countryCode: controller.currentUser.value?.countryCode ?? '+44',
          isLightSurface: true,
          readOnly: true,
          suffixAction: Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
            child: controller.isStartingPhoneChange.value
                ? const AppInlineLoader()
                : GestureDetector(
                    onTap: controller.beginPhoneChange,
                    child: Text(
                      'CHANGE',
                      style: AppTextStyles.pXSmallSemiBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
        ));
  }
}

class _EmailRow extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Obx(() {
                  final email = controller.currentUser.value?.email ?? '';
                  return Text(
                    email.isEmpty ? 'No email set' : email,
                    style: AppTextStyles.pSmall.copyWith(
                      color: email.isEmpty
                          ? AppColors.lightSurfaceSubtitle
                          : AppColors.lightSurfaceText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
            child: Obx(
              () => controller.isStartingEmailChange.value
                  ? const AppInlineLoader()
                  : GestureDetector(
                      onTap: controller.beginEmailChange,
                      child: Text(
                        'CHANGE',
                        style: AppTextStyles.pXSmallSemiBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountRow extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.md,
        child: Obx(() => InkWell(
              onTap: controller.isLoading.value
                  ? null
                  : controller.deleteAccount,
              borderRadius: AppRadius.md,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingMd,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppDimensions.gapMd),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: AppTextStyles.pSmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppDimensions.iconXs,
                      color: AppColors.lightSurfaceHint,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

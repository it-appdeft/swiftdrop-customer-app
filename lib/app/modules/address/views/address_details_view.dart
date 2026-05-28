import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/address_controller.dart';

class AddressDetailsView extends GetView<AddressController> {
  const AddressDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    final addressLine1 = args['address_line_1'] as String? ?? '';
    final city = args['city'] as String? ?? '';
    final county = args['county'] as String? ?? '';
    final postcode = args['postcode'] as String? ?? '';
    final lat = (args['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (args['lng'] as num?)?.toDouble() ?? 0.0;

    controller.prefillPostcodeIfAdding(postcode);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'Address details',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Additional details *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.additionalDetailsController,
                    hintText: 'eg. house number or name',
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Postcode *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.postcodeController,
                    hintText: 'eg. SW12AB',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Delivery Instructions (optional)',
                    style: AppTextStyles.pLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionsBox(),
                  const SizedBox(height: 16),
                  _buildAddressTypeSelector(),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.selectedAddressType.value == 'Others') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Add a label *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: controller.otherLabelController,
                            hintText: '(e.g school)',
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 30, 20 + MediaQuery.of(context).padding.bottom),
            child: Obx(() => AppButton(
              label: 'Save Address',
              onTap: controller.isSaving.value
                  ? null
                  : () => controller.saveAddress(
                        addressLine1: addressLine1,
                        city: city,
                        county: county,
                        lat: lat,
                        lng: lng,
                      ),
              isLoading: controller.isSaving.value,
              backgroundColor: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              height: 56,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    if (text.contains('*')) {
      final parts = text.split('*');
      return RichText(
        text: TextSpan(
          text: parts[0],
          style: AppTextStyles.pSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.lightSurfaceLabel,
          ),
          children: [
            TextSpan(
              text: '*',
              style: TextStyle(color: AppColors.error),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts[1],
                style: AppTextStyles.pSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSurfaceLabel,
                ),
              ),
          ],
        ),
      );
    }
    return Text(
      text,
      style: AppTextStyles.pSmall.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.lightSurfaceLabel,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceDarkText),
      ),
    );
  }

  Widget _buildInstructionsBox() {
    return Container(
      height: 158,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller.instructionsController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Instruction to reach',
                hintStyle: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceHint),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceDarkText),
            ),
          ),
          Container(
            height: 32,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(7)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Example: Take the first left next to red gate',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Row(
      children: [
        Expanded(child: _buildTypeButton(asset: Assets.images.home, label: 'Set home', type: 'Home')),
        const SizedBox(width: 8),
        Expanded(child: _buildTypeButton(asset: Assets.images.work, label: 'Work', type: 'Work')),
        const SizedBox(width: 8),
        Expanded(child: _buildTypeButton(asset: Assets.images.otherLocation, label: 'Others', type: 'Others')),
      ],
    );
  }

  Widget _buildTypeButton({required AssetGenImage asset, required String label, required String type}) {
    return Obx(() {
      final isSelected = controller.selectedAddressType.value == type;
      return GestureDetector(
        onTap: () => controller.setAddressType(type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightSurfaceBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              asset.image(
                width: 20,
                height: 20,
                color: AppColors.lightSurfaceDarkText,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceDarkText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

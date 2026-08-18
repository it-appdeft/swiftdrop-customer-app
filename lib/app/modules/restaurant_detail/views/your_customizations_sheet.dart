import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import 'product_addons_sheet.dart';

void showYourCustomizationsSheet(Map item) {
  Get.bottomSheet(
    YourCustomizationsContent(item: item),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class YourCustomizationsContent extends StatefulWidget {
  final Map item;
  const YourCustomizationsContent({super.key, required this.item});

  @override
  State<YourCustomizationsContent> createState() => _YourCustomizationsContentState();
}

class _YourCustomizationsContentState extends State<YourCustomizationsContent> {
  final List<Map<String, dynamic>> _mockCustomizations = [
    {
      'id': 101,
      'name': 'Regular',
      'price': 8.23,
      'isVeg': true,
      'quantity': 1,
    },
    {
      'id': 102,
      'name': 'Medium',
      'price': 10.23,
      'isVeg': true,
      'quantity': 1,
    },
  ];

  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _mockCustomizations.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.lightSurfaceBorder, height: 32),
                itemBuilder: (context, index) => _buildCustomizationItem(_mockCustomizations[index]),
              ),
            ),
            const SizedBox(height: 24),
            _buildAddNewButton(),
            if (_hasChanges) _buildConfirmButton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.item['name'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: AppColors.iconDark, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your Customisations',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationItem(Map<String, dynamic> custom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Assets.images.vegIcon.image(width: 16, height: 16),
            GestureDetector(
              onTap: () {
                Get.back();
                showProductAddonsSheet(widget.item);
              },
              child: Row(
                children: [
                  Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.lightSurfaceDarkText),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    custom['name'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '£${custom['price'].toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantitySelector(custom),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(Map<String, dynamic> custom) {
    return Container(
      width: 112,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQtyBtn(Assets.images.cartMinus, () {
            if (custom['quantity'] > 0) {
              setState(() {
                custom['quantity']--;
                _hasChanges = true;
              });
            }
          }),
          Text(
            '${custom['quantity']}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          _buildQtyBtn(Assets.images.cartPlus, () {
            setState(() {
              custom['quantity']++;
              _hasChanges = true;
            });
          }, isAdd: true),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(AssetGenImage icon, VoidCallback onTap, {bool isAdd = false}) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: icon.image(
        width: 32,
        height: 32,
      ),
    );
  }

  Widget _buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        Get.back();
        showProductAddonsSheet(widget.item);
      },
      child: Text(
        'Add new customisation',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: AppButton(
        label: 'Confirm',
        onTap: () {
          // In real implementation, this would sync the changes back to the cart
          Get.back();
        },
      ),
    );
  }
}

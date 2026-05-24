import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

void showProductAddonsSheet(Map dish) {
  Get.bottomSheet(
    ProductAddonsContent(dish: dish),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class ProductAddonsContent extends StatefulWidget {
  final Map dish;
  const ProductAddonsContent({super.key, required this.dish});

  @override
  State<ProductAddonsContent> createState() => _ProductAddonsContentState();
}

class _ProductAddonsContentState extends State<ProductAddonsContent> {
  int _quantity = 1;
  String _selectedSize = 'Regular (serves 1,17 Cm)';
  final Set<String> _selectedToppings = {};
  final Set<String> _selectedCheeseDips = {};

  final List<Map<String, dynamic>> _sizes = [
    {'name': 'Regular (serves 1,17 Cm)', 'price': 8.23},
    {'name': 'Medium (serves 2,25 Cm)', 'price': 10.02},
    {'name': 'Large (serves 4,33 Cm)', 'price': 15.00},
  ];

  final List<Map<String, dynamic>> _toppings = [
    {'name': 'Paneer', 'price': 1.00},
    {'name': 'Onions', 'price': 2.00},
    {'name': 'Olives', 'price': 1.00},
    {'name': 'Jalapenos', 'price': 2.00},
    {'name': 'Red Paprika', 'price': 1.00},
    {'name': 'Pineapples', 'price': 2.00},
    {'name': 'Sweet Corns', 'price': 2.00},
  ];

  final List<Map<String, dynamic>> _cheeseDips = [
    {'name': 'Extra Cheese', 'price': 1.00},
    {'name': 'Cheese Dip', 'price': 2.00},
    {'name': 'Jalapeno Dip', 'price': 1.00},
    {'name': 'Hot & Garlic Dip', 'price': 2.00},
    {'name': 'Peri Peri Dip', 'price': 1.00},
    {'name': 'Mozzarella', 'price': 2.00},
  ];

  double get _currentPrice {
    double total = 0;
    final size = _sizes.firstWhere((s) => s['name'] == _selectedSize, orElse: () => _sizes[0]);
    total += size['price'];

    for (var t in _toppings) {
      if (_selectedToppings.contains(t['name'])) {
        total += t['price'];
      }
    }
    for (var c in _cheeseDips) {
      if (_selectedCheeseDips.contains(c['name'])) {
        total += c['price'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(),
                  const SizedBox(height: 16),
                  _buildProductInfo(),
                  const SizedBox(height: 24),
                  _buildAddonSection(
                    title: 'Size',
                    items: _sizes,
                    isSingleSelection: true,
                    selectedItem: _selectedSize,
                    onTap: (name) => setState(() => _selectedSize = name),
                    showDivider: false,
                  ),
                  _buildAddonSection(
                    title: 'Toppings-Veg (Regular)',
                    items: _toppings,
                    isSingleSelection: false,
                    selectedItems: _selectedToppings,
                    onTap: (name) {
                      setState(() {
                        if (_selectedToppings.contains(name)) {
                          _selectedToppings.remove(name);
                        } else {
                          _selectedToppings.add(name);
                        }
                      });
                    },
                  ),
                  _buildAddonSection(
                    title: 'Cheese & Dip',
                    items: _cheeseDips,
                    isSingleSelection: false,
                    selectedItems: _selectedCheeseDips,
                    onTap: (name) {
                      setState(() {
                        if (_selectedCheeseDips.contains(name)) {
                          _selectedCheeseDips.remove(name);
                        } else {
                          _selectedCheeseDips.add(name);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, color: AppColors.iconDark),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Assets.images.onbording1.image(
        width: double.infinity,
        height: 208,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Margherita Pizza Giant Slice',
          style: TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Onion, Marinated paneer cubes topped with extra cheese and tandoori sauce',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF868AA5),
          ),
        ),
      ],
    );
  }

  Widget _buildAddonSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required bool isSingleSelection,
    String? selectedItem,
    Set<String>? selectedItems,
    required Function(String) onTap,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider)
          const Divider(color: Color(0xFFF2F2E9), thickness: 1, height: 48),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
        ),
        ...items.map((item) {
          final isItemSelected = isSingleSelection
              ? selectedItem == item['name']
              : selectedItems!.contains(item['name']);

          return _buildSelectionItem(
            title: item['name'],
            price: isSingleSelection
                ? '£${item['price'].toStringAsFixed(2)}'
                : '+£${item['price'].toStringAsFixed(2)}',
            isSelected: isItemSelected,
            isSingleSelection: isSingleSelection,
            onTap: () => onTap(item['name']),
          );
        }),
        if (!showDivider) const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildSelectionItem({
    required String title,
    required String price,
    required bool isSelected,
    required bool isSingleSelection,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Assets.images.vegIcon.image(width: 16, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF595D70),
              ),
            ),
            const SizedBox(width: 12),
            if (isSingleSelection)
              _buildRadioButton(isSelected)
            else
              isSelected
                  ? Assets.images.checkButton.image(width: 24, height: 24)
                  : Assets.images.unCheckButton.image(width: 24, height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFCFD1DC),
          width: 1,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFF2F2E9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF2F2E9)),
              ),
              child: Row(
                children: [
                  _buildQtyBtn(Assets.images.minus, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_quantity',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  _buildQtyBtn(Assets.images.plus, () {
                    setState(() => _quantity++);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Close the addons sheet
                Get.back();
                // Close the product detail sheet if it's still open
                if (Get.isBottomSheetOpen ?? false) {
                  Get.back();
                }
                // Go to cart
                Get.toNamed(AppRoutes.cart);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add Item £${(_currentPrice * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // PS Size
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(AssetGenImage icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: icon.image(width: 20, height: 20, color: AppColors.primary),
      ),
    );
  }
}

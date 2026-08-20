import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

import '../../cart/controllers/cart_controller.dart';
import '../controllers/restaurant_detail_controller.dart';

void showProductAddonsSheet(
  Map item, {
  List<CartApiModifier>? existingModifiers,
  int? editingCartItemId,
  int? editingQuantity,
}) {
  Get.bottomSheet(
    ProductAddonsContent(
      item: item,
      existingModifiers: existingModifiers,
      editingCartItemId: editingCartItemId,
      editingQuantity: editingQuantity,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class ProductAddonsContent extends StatefulWidget {
  final Map item;
  final List<CartApiModifier>? existingModifiers;
  final int? editingCartItemId;
  final int? editingQuantity;

  const ProductAddonsContent({
    super.key,
    required this.item,
    this.existingModifiers,
    this.editingCartItemId,
    this.editingQuantity,
  });

  @override
  State<ProductAddonsContent> createState() => _ProductAddonsContentState();
}

class _ProductAddonsContentState extends State<ProductAddonsContent> {
  int _quantity = 1;
  bool _isAddingToCart = false;
  final Map<int, int?> _singleSelections = {};
  final Map<int, Set<int>> _multiSelections = {};

  @override
  void initState() {
    super.initState();
    _initQuantity();
    _initSelections();
  }

  void _initQuantity() {
    if (widget.editingQuantity != null && widget.editingQuantity! > 0) {
      _quantity = widget.editingQuantity!;
      return;
    }
    if (widget.existingModifiers == null) return;
    try {
      final cart = Get.find<CartController>();
      final itemId = (widget.item['id'] as int?) ?? 0;
      final qty = cart.quantities[itemId] ?? 1;
      if (qty > 0) _quantity = qty;
    } catch (_) {}
  }

  void _initSelections() {
    final existing = widget.existingModifiers ?? [];
    for (final group in _groups) {
      if (group.selectionType == 'single') {
        CartApiModifier? match;
        for (final m in existing) {
          if (m.groupId == group.id) { match = m; break; }
        }
        if (match != null) {
          _singleSelections[group.id] = match.optionId;
        } else if (group.isRequired && group.options.isNotEmpty) {
          _singleSelections[group.id] = group.options[0].id;
        }
      } else {
        final selectedIds = <int>{};
        for (final m in existing) {
          if (m.groupId == group.id) selectedIds.add(m.optionId);
        }
        if (selectedIds.isNotEmpty) {
          _multiSelections[group.id] = selectedIds;
        }
      }
    }
  }

  List<ModifierGroupModel> get _groups =>
      (widget.item['modifier_groups'] as List?)
          ?.whereType<ModifierGroupModel>()
          .toList() ??
      [];

  double get _basePrice {
    final raw = widget.item['price'] ?? widget.item['base_price'];
    return double.tryParse(raw?.toString() ?? '0') ?? 0;
  }

  double get _currentPrice {
    double delta = 0;

    for (final group in _groups) {
      if (group.selectionType == 'single') {
        final selectedId = _singleSelections[group.id];
        if (selectedId != null) {
          final idx = group.options.indexWhere((o) => o.id == selectedId);
          if (idx != -1) delta += group.options[idx].priceDelta;
        }
      } else {
        final selected = _multiSelections[group.id] ?? {};
        for (final optId in selected) {
          final idx = group.options.indexWhere((o) => o.id == optId);
          if (idx != -1) delta += group.options[idx].priceDelta;
        }
      }
    }
    return _basePrice + delta;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
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
                  ...groups.asMap().entries.map((entry) =>
                      _buildGroupSection(entry.value, showDivider: entry.key > 0)),
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
      child: AppImage(
        path: widget.item['image'] as String?,
        width: double.infinity,
        height: 208,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProductInfo() {
    final description = widget.item['description'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item['name'] as String? ?? '',
          style: const TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF868AA5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupSection(ModifierGroupModel group,
      {required bool showDivider}) {
    final isSingle = group.selectionType == 'single';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider)
          const Divider(color: Color(0xFFF2F2E9), thickness: 1, height: 48),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            group.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...group.options.map((opt) {
          final isSelected = isSingle
              ? _singleSelections[group.id] == opt.id
              : (_multiSelections[group.id] ?? {}).contains(opt.id);
          final priceLabel = opt.priceDelta == 0
              ? ''
              : opt.priceDelta > 0
                  ? '+£${opt.priceDelta.toStringAsFixed(2)}'
                  : '-£${opt.priceDelta.abs().toStringAsFixed(2)}';
          return _buildSelectionItem(
            title: opt.name,
            price: priceLabel,
            isSelected: isSelected,
            isSingleSelection: isSingle,
            onTap: () {
              setState(() {
                if (isSingle) {
                  _singleSelections[group.id] = opt.id;
                } else {
                  final set =
                      _multiSelections.putIfAbsent(group.id, () => {});
                  if (set.contains(opt.id)) {
                    set.remove(opt.id);
                  } else {
                    set.add(opt.id);
                  }
                }
              });
            },
          );
        }),
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
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
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
            if (price.isNotEmpty) ...[
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF595D70),
                ),
              ),
              const SizedBox(width: 12),
            ],
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
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
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
              onTap: _isAddingToCart
                  ? null
                  : () async {
                      setState(() => _isAddingToCart = true);

                      final menuItemId = (widget.item['id'] as int?) ?? 0;
                      final selectedOptionIds = <int>[];
                      for (final group in _groups) {
                        if (group.selectionType == 'single') {
                          final selectedId = _singleSelections[group.id];
                          if (selectedId != null)
                            selectedOptionIds.add(selectedId);
                        } else {
                          selectedOptionIds
                              .addAll(_multiSelections[group.id] ?? {});
                        }
                      }

                      try {
                        final bool? itemIsOpen = widget.item['is_open_now'] as bool?;
                        final bool? itemIsAccepting = widget.item['is_accepting_orders'] as bool?;
                        bool isClosed = false;
                        if (itemIsOpen != null || itemIsAccepting != null) {
                          if (!(itemIsOpen ?? true) || !(itemIsAccepting ?? true)) {
                            isClosed = true;
                          }
                        } else {
                          final info = Get.find<RestaurantDetailController>().restaurantInfo.value;
                          if (info != null && (!info.isOpenNow || !info.isAcceptingOrders)) {
                            isClosed = true;
                          }
                        }
                        if (isClosed) {
                          setState(() => _isAddingToCart = false);
                          AppUtils.showError("This restaurant is currently closed for ordering.");
                          return;
                        }
                      } catch (_) {}

                      try {
                        int? rId = widget.item['restaurant_id'] as int?;
                        if (rId == null) {
                          try {
                            rId = Get.find<RestaurantDetailController>().restaurantId;
                          } catch (_) {}
                        }

                        final bool isEditing = widget.editingCartItemId != null;
                        final result = isEditing
                            ? await Get.find<CartController>().updateCartItemApi(
                                widget.editingCartItemId!,
                                selectedOptionIds,
                                _quantity,
                              )
                            : await Get.find<CartController>().addToCartApi(
                                menuItemId,
                                selectedOptionIds,
                                _quantity,
                                restaurantId: rId,
                              );
                        
                        if (result.success) {
                          try {
                            Get.find<RestaurantDetailController>()
                                .showCartFloatingBar
                                .value = true;
                          } catch (_) {}

                          if (mounted) setState(() => _isAddingToCart = false);
                          Get.back();
                          if (Get.isBottomSheetOpen ?? false) Get.back();
                        } else {
                          if (mounted) setState(() => _isAddingToCart = false);
                        }
                      } catch (_) {
                        if (mounted) setState(() => _isAddingToCart = false);
                      }
                    },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.editingCartItemId != null
                            ? 'Update Item £${(_currentPrice * _quantity).toStringAsFixed(2)}'
                            : 'Add Item £${(_currentPrice * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: icon.image(width: 20, height: 20, color: AppColors.primary),
      ),
    );
  }
}

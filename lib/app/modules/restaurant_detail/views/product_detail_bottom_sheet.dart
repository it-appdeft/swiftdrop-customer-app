import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import 'product_addons_sheet.dart';

void showProductDetailBottomSheet(Map item) {
  Get.bottomSheet(
    ProductDetailContent(item: item),
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
  );
}

class ProductDetailContent extends StatefulWidget {
  final Map item;
  const ProductDetailContent({super.key, required this.item});

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                      Icons.close, color: AppColors.iconDark, size: 24),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Assets.images.onbording1.image(
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Assets.images.vegIcon.image(width: 16, height: 16),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item['name'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontSize: 24, // H5 Size
                              fontWeight: FontWeight.w500, // Medium
                              color: AppColors.lightSurfaceDarkText,
                              height: 1.2, // H5 LineHeight
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 36,
                          width: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: _quantity == 0
                              ? GestureDetector(
                                  onTap: () {
                                    showProductAddonsSheet(widget.item);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      'ADD',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _quantity > 1 ? _quantity-- : _quantity = 0),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Assets.images.minus.image(width: 24, height: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$_quantity',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => setState(() => _quantity++),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Assets.images.plus.image(width: 24, height: 24),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '£${widget.item['price']}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceLabel,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'A giant slice of classic Margherita pizza topped with onions, marinated paneer cubes, extra cheese, and rich tandoori sauce for a bold and satisfying flavor.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

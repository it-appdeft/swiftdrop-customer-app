import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../restaurant_detail/views/product_addons_sheet.dart';
import '../controllers/cart_controller.dart';

void showRepeatLastSheet(Map item, {VoidCallback? onRepeat}) {
  Get.bottomSheet(
    RepeatLastContent(item: item, onRepeat: onRepeat),
    backgroundColor: Colors.transparent,
  );
}

class RepeatLastContent extends StatelessWidget {
  final Map item;
  final VoidCallback? onRepeat;
  const RepeatLastContent({super.key, required this.item, this.onRepeat});

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Assets.images.vegIcon.image(width: 16, height: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '£${price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: AppColors.iconDark),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    showProductAddonsSheet(item);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B94A3),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    "I'll Choose",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onRepeat?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    'Repeat Last',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

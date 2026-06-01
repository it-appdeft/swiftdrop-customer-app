import 'package:swiftdrop_customer_app/export.dart';

class AppTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool expand;

  const AppTabItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget textPart = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: isSelected ? AppColors.lightSurfaceDarkText : AppColors.navyMedium,
        ),
      ),
    );

    Widget content = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          expand ? Center(child: textPart) : textPart,
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ),
        ],
      ),
    );

    if (!expand) {
      return IntrinsicWidth(child: content);
    }

    return content;
  }
}

import 'package:swiftdrop_customer_app/export.dart';

class NoDataWidget extends StatelessWidget {
  final Widget image;
  final String title;
  final String subtitle;

  const NoDataWidget({
    super.key,
    required this.image,
    this.title = 'No Result Found',
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.pMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.noDataSubtitle,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

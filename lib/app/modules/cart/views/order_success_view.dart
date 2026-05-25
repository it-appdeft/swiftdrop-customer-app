import 'package:swiftdrop_customer_app/export.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Order Placed Successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been confirmed and\nis being prepared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Go to Home',
                onTap: () => Get.offAllNamed(AppRoutes.dashboard),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

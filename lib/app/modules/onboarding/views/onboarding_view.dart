import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Full-screen paged images
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.pages.length,
            itemBuilder: (_, index) => Image.asset(
              controller.pages[index]['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Gradient overlay — transparent top, dark bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.97),
                  ],
                  stops: const [0.25, 0.45, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Skip button — visible only on pages 1 & 2
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Obx(() {
                if (controller.currentPage.value == controller.pages.length - 1) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: controller.completeOnboarding,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.paddingLg,
                      right: AppDimensions.paddingMd,
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.smd,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.87, sigmaY: 5.87),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingLg,
                            vertical: AppDimensions.paddingXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.22),
                            borderRadius: AppRadius.smd,
                          ),
                          child: Text(
                            'Skip',
                            style: AppTextStyles.pSmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Bottom content: title, subtitle, dots, button — all center-aligned
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingXl,
                  0,
                  AppDimensions.paddingXl,
                  AppDimensions.paddingXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      final page = controller.pages[controller.currentPage.value];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                if (page['titleBefore']!.isNotEmpty)
                                  TextSpan(
                                    text: page['titleBefore']!,
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                TextSpan(
                                  text: page['titleHighlight']!,
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                if ((page['titleAfter'] ?? '').isNotEmpty)
                                  TextSpan(
                                    text: page['titleAfter']!,
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.gapMd),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingLg,
                            ),
                            child: Text(
                              page['subtitle']!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.pSmall.copyWith(
                                color: AppColors.offWhite,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: AppDimensions.gapXl),

                    // Dot indicators — centered
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.pages.length,
                            (i) => _DotIndicator(
                              key: ValueKey('dot_$i'),
                              isActive: i == controller.currentPage.value,
                            ),
                          ),
                        )),

                    const SizedBox(height: AppDimensions.gapXl),

                    // Next / Get Started button
                    Obx(() => AppButton(
                          label: controller.currentPage.value ==
                                  controller.pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onTap: controller.nextPage,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: AppDimensions.gapSm),
      width: isActive ? AppDimensions.gapMd : AppDimensions.gapSm,
      height: isActive ? AppDimensions.gapMd : AppDimensions.gapSm,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.25),
        borderRadius: AppRadius.full,
      ),
    );
  }
}

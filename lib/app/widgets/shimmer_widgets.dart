import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_radius.dart';

class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
    this.margin,
  });

  static const Color baseColor = AppColors.lightSurfaceDisabled;
  static const Color highlightColor = AppColors.offWhite;

  factory AppShimmer.circle({Key? key, required double size}) => AppShimmer(
        key: key,
        width: size,
        height: size,
        shape: const CircleBorder(),
      );

  factory AppShimmer.text({
    Key? key,
    double width = double.infinity,
    double height = 12,
  }) =>
      AppShimmer(
        key: key,
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      );

  factory AppShimmer.rect({
    Key? key,
    required double width,
    required double height,
    double radius = AppDimensions.radiusSm,
  }) =>
      AppShimmer(
        key: key,
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(radius),
      );

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: ShapeDecoration(
        color: baseColor,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: borderRadius ??
                  BorderRadius.circular(AppDimensions.radiusSm),
            ),
      ),
    );
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({super.key});

  static Container _block({
    double? width,
    required double height,
    double radius = AppDimensions.radiusXs,
    BoxShape shape = BoxShape.rectangle,
  }) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppShimmer.baseColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppShimmer.baseColor,
      highlightColor: AppShimmer.highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(height: 210, radius: 8),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _block(height: 20)),
                const SizedBox(width: 12),
                _block(height: 24, width: 24, shape: BoxShape.circle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _block(height: 20, width: 20, shape: BoxShape.circle),
                const SizedBox(width: 8),
                _block(width: 80, height: 14),
                const SizedBox(width: 18),
                _block(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemCardShimmer extends StatelessWidget {
  const MenuItemCardShimmer({super.key});

  static Container _block({
    double? width,
    required double height,
    double radius = AppDimensions.radiusXs,
  }) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppShimmer.baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppShimmer.baseColor,
      highlightColor: AppShimmer.highlightColor,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(width: 154, height: 144, radius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(width: 16, height: 16),
                  const SizedBox(height: 4),
                  _block(height: 16),
                  const SizedBox(height: 4),
                  _block(width: 80, height: 14),
                  const SizedBox(height: 4),
                  _block(width: 52, height: 22, radius: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppShimmer.baseColor,
      highlightColor: AppShimmer.highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.gapMd),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.avatarMd,
                height: AppDimensions.avatarMd,
                decoration: BoxDecoration(
                  color: AppShimmer.baseColor,
                  borderRadius: AppRadius.sm,
                ),
              ),
              const SizedBox(width: AppDimensions.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppShimmer.baseColor,
                        borderRadius: AppRadius.xs,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapSm),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppShimmer.baseColor,
                        borderRadius: AppRadius.xs,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

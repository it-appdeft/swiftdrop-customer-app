import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_radius.dart';

/// Default shimmer palette tuned for light surfaces (offWhite / white).
/// Pass `baseColor` / `highlightColor` to override on dark backgrounds.
class _ShimmerColors {
  static const Color base = AppColors.lightSurfaceDisabled;
  static const Color highlight = AppColors.offWhite;
}

Widget _wrap({
  required Widget child,
  Color? baseColor,
  Color? highlightColor,
}) {
  return Shimmer.fromColors(
    baseColor: baseColor ?? _ShimmerColors.base,
    highlightColor: highlightColor ?? _ShimmerColors.highlight,
    child: child,
  );
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppDimensions.radiusSm,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return _wrap(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor ?? _ShimmerColors.base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return _wrap(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: baseColor ?? _ShimmerColors.base,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerListTile({super.key, this.baseColor, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? _ShimmerColors.base;
    final highlight = highlightColor ?? _ShimmerColors.highlight;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapSm,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: base,
          borderRadius: AppRadius.md,
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.avatarMd,
              height: AppDimensions.avatarMd,
              decoration: BoxDecoration(
                color: highlight,
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: highlight,
                      borderRadius: AppRadius.xs,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapSm),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: highlight,
                      borderRadius: AppRadius.xs,
                    ),
                  ),
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
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, _) => ShimmerListTile(
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }
}

/// Skeleton matching the RestaurantCard layout (image + name + meta row).
class ShimmerRestaurantSearchCard extends StatelessWidget {
  const ShimmerRestaurantSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerColors.base,
      highlightColor: _ShimmerColors.highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 210,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _ShimmerColors.base,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: _ShimmerColors.base,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _ShimmerColors.base,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 14,
              width: 160,
              decoration: BoxDecoration(
                color: _ShimmerColors.base,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton matching the RestaurantWithItems layout (header + horizontal item cards).
class ShimmerItemGroupCard extends StatelessWidget {
  const ShimmerItemGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerColors.base,
      highlightColor: _ShimmerColors.highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        color: _ShimmerColors.highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 28, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: 140,
                          decoration: BoxDecoration(
                            color: _ShimmerColors.base,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: _ShimmerColors.base,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _ShimmerColors.base,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 174,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 36),
                itemCount: 3,
                itemBuilder: (_, __) => Container(
                  width: 330,
                  height: 160,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _ShimmerColors.highlight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 128,
                        height: 119,
                        decoration: BoxDecoration(
                          color: _ShimmerColors.base,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: _ShimmerColors.base,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: _ShimmerColors.base,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 60,
                              decoration: BoxDecoration(
                                color: _ShimmerColors.base,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.borderRadius = AppDimensions.radiusMd,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return _wrap(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapSm,
        ),
        decoration: BoxDecoration(
          color: baseColor ?? _ShimmerColors.base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

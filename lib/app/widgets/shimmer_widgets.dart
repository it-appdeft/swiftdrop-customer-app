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

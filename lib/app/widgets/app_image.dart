import 'package:swiftdrop_customer_app/export.dart';

class AppImage extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? fallback;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.fallback,
  });

  static String buildUrl(String path) {
    if (path.startsWith('http')) return path;

    final base = AppConfig.imageBaseUrl;
    if (base.isEmpty) return path;

    try {
      final uri = Uri.parse(base);
      final origin = '${uri.scheme}://${uri.host}';
      final cleanPath = path.startsWith('/') ? path : '/$path';
      return '$origin$cleanPath';
    } catch (_) {
      final cleanPath = path.startsWith('/') ? path : '/$path';
      return '$base$cleanPath';
    }
  }

  Widget _shimmer(BoxConstraints? constraints) {
    return ShimmerBox(
      width: width ?? constraints?.maxWidth ?? double.infinity,
      height: height ?? constraints?.maxHeight ?? double.infinity,
      borderRadius: borderRadius,
    );
  }

  Widget _placeholder(BoxConstraints? constraints) {
    final w = width ?? constraints?.maxWidth ?? double.infinity;
    final h = height ?? constraints?.maxHeight ?? double.infinity;
    return Container(
      width: w,
      height: h,
      color: const Color(0xFFEEEEEE),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.trim().isEmpty) {
      return fallback ?? LayoutBuilder(builder: (_, c) => _placeholder(c));
    }

    final url = buildUrl(path!);

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => LayoutBuilder(builder: (_, c) => _shimmer(c)),
      errorWidget: (_, __, ___) {
        AppLogger.w('AppImage failed to load: $url');
        return fallback ?? LayoutBuilder(builder: (_, c) => _placeholder(c));
      },
    );

    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }
}

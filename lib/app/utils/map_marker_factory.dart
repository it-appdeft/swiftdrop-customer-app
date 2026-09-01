import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../generated/assets.dart';
import '../themes/app_colors.dart';
import '../widgets/app_image.dart';
import 'app_logger.dart';

/// Builds map pins at runtime so marker artwork can come from API data
/// (restaurant logo) instead of a bundled fixed image.
class MapMarkerFactory {
  MapMarkerFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    responseType: ResponseType.bytes,
  ));

  static const double _pinDiameter = 32;
  static const double _pinTail = 8;

  static void clearCache() => _cache.clear();

  static Future<BitmapDescriptor> restaurantPin([String? imageUrl]) async {
    const double size = 42;
    const double tailHeight = 8;
    final cacheKey = 'restaurant_pin::v7::${imageUrl ?? 'fallback'}';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    ui.Image? photo;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        photo = await _loadNetworkImage(AppImage.buildUrl(imageUrl.trim())).timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
    photo ??= await _loadAssetImage(Assets.images.restaurantImage.path);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    final radius = size / 2 - 2;

    canvas.drawCircle(
      center.translate(0, 2),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final tail = Path()
      ..moveTo(size / 2 - 5, size / 2 + radius - 2)
      ..lineTo(size / 2, size + tailHeight)
      ..lineTo(size / 2 + 5, size / 2 + radius - 2)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.primary);

    canvas.drawCircle(center, radius, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, radius - 2.5, Paint()..color = Colors.white);

    if (photo != null) {
      final innerRadius = radius - 3.5;
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius)));
      _drawContain(canvas, photo, Rect.fromCircle(center: center, radius: innerRadius));
      canvas.restore();
      photo.dispose();
    } else {
      canvas.drawCircle(center, radius - 3.5, Paint()..color = AppColors.primary);
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.restaurant_rounded.codePoint),
          style: TextStyle(
            fontSize: 20,
            fontFamily: Icons.restaurant_rounded.fontFamily,
            package: Icons.restaurant_rounded.fontPackage,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    final descriptor = await _finish(recorder, size, size + tailHeight);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> driverPin([String? imageUrl]) async {
    const double size = 46;
    const double tailHeight = 8;
    const cacheKey = 'driver_bike_marker::v8';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    final radius = size / 2 - 2;

    // Drop shadow
    canvas.drawCircle(
      center.translate(0, 2),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    // Pointer tail
    final tail = Path()
      ..moveTo(size / 2 - 5, size / 2 + radius - 2)
      ..lineTo(size / 2, size + tailHeight)
      ..lineTo(size / 2 + 5, size / 2 + radius - 2)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.primary);

    // Primary border circle
    canvas.drawCircle(center, radius, Paint()..color = AppColors.primary);
    // Inner white disc
    canvas.drawCircle(center, radius - 2.5, Paint()..color = Colors.white);

    // Primary inner circle with bold white delivery bike icon
    canvas.drawCircle(center, radius - 4.0, Paint()..color = AppColors.primary);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.delivery_dining_rounded.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: Icons.delivery_dining_rounded.fontFamily,
          package: Icons.delivery_dining_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    final descriptor = await _finish(recorder, size, size + tailHeight);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> homePin() async {
    const double size = 42;
    const double tailHeight = 8;
    const cacheKey = 'home_pin::v7';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    final radius = size / 2 - 2;

    canvas.drawCircle(
      center.translate(0, 2),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final tail = Path()
      ..moveTo(size / 2 - 5, size / 2 + radius - 2)
      ..lineTo(size / 2, size + tailHeight)
      ..lineTo(size / 2 + 5, size / 2 + radius - 2)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.lightSurfaceNavy);

    canvas.drawCircle(center, radius, Paint()..color = AppColors.lightSurfaceNavy);
    canvas.drawCircle(center, radius - 2.5, Paint()..color = Colors.white);

    canvas.drawCircle(center, radius - 3.5, Paint()..color = AppColors.lightSurfaceNavy);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.home_rounded.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: Icons.home_rounded.fontFamily,
          package: Icons.home_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    final descriptor = await _finish(recorder, size, size + tailHeight);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> currentLocationPin() async {
    const key = 'current_location::v4';
    final cached = _cache[key];
    if (cached != null) return cached;

    const double size = 28;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);

    canvas.drawCircle(
      center,
      size / 2,
      Paint()..color = AppColors.primary.withValues(alpha: 0.18),
    );
    canvas.drawCircle(center, size / 4 + 2, Paint()..color = Colors.white);
    canvas.drawCircle(center, size / 4, Paint()..color = AppColors.primary);

    final descriptor = await _finish(recorder, size, size);
    _cache[key] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> _photoPin({
    required String cacheKey,
    required String? imageUrl,
    required String fallbackAsset,
    required Color ring,
  }) async {
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    ui.Image? photo;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      photo = await _loadNetworkImage(AppImage.buildUrl(imageUrl.trim()));
    }
    photo ??= await _loadAssetImage(fallbackAsset);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _paintPinBase(canvas, ring);

    if (photo != null) {
      const center = Offset(_pinDiameter / 2, _pinDiameter / 2);
      final radius = _pinDiameter / 2 - 3;
      canvas.save();
      canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
      _drawContain(canvas, photo,
          Rect.fromCircle(center: center, radius: radius));
      canvas.restore();
      photo.dispose();
    }

    final descriptor =
        await _finish(recorder, _pinDiameter, _pinDiameter + _pinTail);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> _iconPin({
    required String cacheKey,
    required String assetPath,
    required Color ring,
  }) async {
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _paintPinBase(canvas, ring);

    final icon = await _loadAssetImage(assetPath);
    if (icon != null) {
      const center = Offset(_pinDiameter / 2, _pinDiameter / 2);
      const iconSize = _pinDiameter * 0.55;
      _drawContain(
        canvas,
        icon,
        Rect.fromCenter(center: center, width: iconSize, height: iconSize),
      );
      icon.dispose();
    }

    final descriptor =
        await _finish(recorder, _pinDiameter, _pinDiameter + _pinTail);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static void _paintPinBase(Canvas canvas, Color ring) {
    const center = Offset(_pinDiameter / 2, _pinDiameter / 2);
    final radius = _pinDiameter / 2 - 2;

    canvas.drawCircle(
      center.translate(0, 1),
      radius + 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    final tail = Path()
      ..moveTo(_pinDiameter / 2 - 4, _pinDiameter / 2 + radius - 2)
      ..lineTo(_pinDiameter / 2, _pinDiameter + _pinTail)
      ..lineTo(_pinDiameter / 2 + 4, _pinDiameter / 2 + radius - 2)
      ..close();
    canvas.drawPath(tail, Paint()..color = ring);

    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = ring,
    );
  }

  static void _drawContain(Canvas canvas, ui.Image image, Rect dst) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final imageAspect = image.width / image.height;
    final dstAspect = dst.width / dst.height;

    Rect drawRect;
    if (imageAspect > dstAspect) {
      final h = dst.width / imageAspect;
      drawRect = Rect.fromLTWH(dst.left, dst.top + (dst.height - h) / 2, dst.width, h);
    } else {
      final w = dst.height * imageAspect;
      drawRect = Rect.fromLTWH(dst.left + (dst.width - w) / 2, dst.top, w, dst.height);
    }

    canvas.drawImageRect(
      image,
      src,
      drawRect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  static Future<BitmapDescriptor> _finish(
    ui.PictureRecorder recorder,
    double width,
    double height,
  ) async {
    final image =
        await recorder.endRecording().toImage(width.ceil(), height.ceil());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  static Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final response = await _dio.get<List<int>>(url);
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;
      return _decode(Uint8List.fromList(bytes));
    } catch (e) {
      AppLogger.w('[MARKER] network image failed: $url | $e');
      return null;
    }
  }

  static Future<ui.Image?> _loadAssetImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      return _decode(data.buffer.asUint8List());
    } catch (e) {
      AppLogger.w('[MARKER] asset image failed: $path | $e');
      return null;
    }
  }

  static Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

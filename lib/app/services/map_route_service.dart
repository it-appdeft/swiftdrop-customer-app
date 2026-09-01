import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/app_config.dart';
import '../utils/app_logger.dart';

/// Contract for anything that can turn an ordered list of stops into a
/// road-following path. Swapping the provider (Directions API, Mapbox, an
/// in-house routing endpoint) never touches the controller or the view.
abstract class RouteProvider {
  Future<List<LatLng>> fetchRoute(List<LatLng> waypoints);
}

class PolylineCodec {
  PolylineCodec._();

  static List<LatLng> decode(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}

class GoogleDirectionsRouteProvider implements RouteProvider {
  static const String _endpoint =
      'https://maps.googleapis.com/maps/api/directions/json';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  @override
  Future<List<LatLng>> fetchRoute(List<LatLng> waypoints) async {
    final key = AppConfig.googleMapsApiKey;
    if (key.isEmpty || waypoints.length < 2) return const [];

    String fmt(LatLng p) => '${p.latitude},${p.longitude}';

    final query = <String, dynamic>{
      'origin': fmt(waypoints.first),
      'destination': fmt(waypoints.last),
      'mode': 'driving',
      'key': key,
    };
    if (waypoints.length > 2) {
      query['waypoints'] =
          waypoints.sublist(1, waypoints.length - 1).map(fmt).join('|');
    }

    final response = await _dio.get(_endpoint, queryParameters: query);
    final data = response.data;
    if (data is! Map || data['status'] != 'OK') {
      AppLogger.w('[ROUTE] Directions status: ${data is Map ? data['status'] : 'invalid'}');
      return const [];
    }

    final routes = data['routes'] as List? ?? const [];
    if (routes.isEmpty) return const [];

    // Per-step geometry gives a far denser path than overview_polyline,
    // which visibly cuts corners at city zoom levels.
    final points = <LatLng>[];
    final legs = (routes.first as Map)['legs'] as List? ?? const [];
    for (final leg in legs) {
      final steps = (leg as Map)['steps'] as List? ?? const [];
      for (final step in steps) {
        final encoded = ((step as Map)['polyline'] as Map?)?['points'];
        if (encoded is String && encoded.isNotEmpty) {
          points.addAll(PolylineCodec.decode(encoded));
        }
      }
    }
    if (points.isNotEmpty) return points;

    final overview = (routes.first as Map)['overview_polyline'];
    final encoded = overview is Map ? overview['points'] : null;
    if (encoded is String && encoded.isNotEmpty) {
      return PolylineCodec.decode(encoded);
    }
    return const [];
  }
}

class OsrmRouteProvider implements RouteProvider {
  static const String _endpoint =
      'https://router.project-osrm.org/route/v1/driving';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  Future<List<LatLng>> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return const [];
    try {
      final coords =
          waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = '$_endpoint/$coords';
      final response = await _dio.get(url, queryParameters: {
        'overview': 'full',
        'geometries': 'polyline',
        'steps': 'false',
      });
      final data = response.data;
      if (data is Map && data['code'] == 'Ok') {
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final geom = routes.first['geometry'];
          if (geom is String && geom.isNotEmpty) {
            final points = PolylineCodec.decode(geom);
            if (points.length >= 2) {
              AppLogger.i('[ROUTE] OSRM route fetched with ${points.length} road coordinates');
              return points;
            }
          }
        }
      }
    } catch (e) {
      AppLogger.w('[ROUTE] OSRM route request failed | $e');
    }
    return const [];
  }
}

class CompositeRouteProvider implements RouteProvider {
  final GoogleDirectionsRouteProvider _google = GoogleDirectionsRouteProvider();
  final OsrmRouteProvider _osrm = OsrmRouteProvider();

  @override
  Future<List<LatLng>> fetchRoute(List<LatLng> waypoints) async {
    // 1. Try Google Directions
    try {
      final googleRoute = await _google.fetchRoute(waypoints);
      if (googleRoute.length >= 2) return googleRoute;
    } catch (_) {}

    // 2. Try OSRM (real road routing fallback)
    try {
      final osrmRoute = await _osrm.fetchRoute(waypoints);
      if (osrmRoute.length >= 2) return osrmRoute;
    } catch (_) {}

    return const [];
  }
}

class MapRouteService {
  MapRouteService({RouteProvider? provider})
      : _provider = provider ?? CompositeRouteProvider();

  final RouteProvider _provider;
  static final Map<String, List<LatLng>> _cache = {};

  /// Returns a drawable path through [waypoints]. Falls back to a smoothed
  /// curve when no routing provider is reachable so the map never shows a
  /// bare straight line.
  Future<List<LatLng>> buildRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return const [];

    final key = waypoints
        .map((p) => '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}')
        .join('|');
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final route = await _provider.fetchRoute(waypoints);
      if (route.length >= 2) {
        _cache[key] = route;
        return route;
      }
    } catch (e) {
      AppLogger.w('[ROUTE] provider failed, using smoothed fallback | $e');
    }

    final fallback = _smoothed(waypoints);
    _cache[key] = fallback;
    return fallback;
  }

  static List<LatLng> _smoothed(List<LatLng> waypoints) {
    final result = <LatLng>[];
    for (var i = 0; i < waypoints.length - 1; i++) {
      final a = waypoints[i];
      final b = waypoints[i + 1];

      final dLat = b.latitude - a.latitude;
      final dLng = b.longitude - a.longitude;
      final control = LatLng(
        (a.latitude + b.latitude) / 2 - dLng * 0.12,
        (a.longitude + b.longitude) / 2 + dLat * 0.12,
      );

      const segments = 24;
      for (var s = 0; s <= segments; s++) {
        if (s == 0 && result.isNotEmpty) continue;
        final t = s / segments;
        final mt = 1 - t;
        result.add(LatLng(
          mt * mt * a.latitude +
              2 * mt * t * control.latitude +
              t * t * b.latitude,
          mt * mt * a.longitude +
              2 * mt * t * control.longitude +
              t * t * b.longitude,
        ));
      }
    }
    return result;
  }

  static LatLngBounds boundsOf(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    // A zero-area bounds makes newLatLngBounds throw on some platforms.
    const pad = 0.0015;
    if ((maxLat - minLat).abs() < pad) {
      minLat -= pad;
      maxLat += pad;
    }
    if ((maxLng - minLng).abs() < pad) {
      minLng -= pad;
      maxLng += pad;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

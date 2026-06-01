import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../utils/app_logger.dart';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final sf = json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      mainText: sf['main_text'] as String? ?? '',
      secondaryText: sf['secondary_text'] as String? ?? '',
    );
  }
}

class DeliveryAddressController extends GetxController {
  final searchController = TextEditingController();
  final RxString query = ''.obs;
  final RxList<PlacePrediction> suggestions = <PlacePrediction>[].obs;
  final RxBool isSearching = false.obs;

  Timer? _debounce;
  final _http = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    query.value = searchController.text;
    _debounce?.cancel();
    if (searchController.text.trim().isEmpty) {
      suggestions.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), _fetchSuggestions);
  }

  Future<void> _fetchSuggestions() async {
    final q = searchController.text.trim();
    if (q.isEmpty) return;
    isSearching.value = true;
    try {
      final response = await _http.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': q,
          'key': AppConfig.googleMapsApiKey,
          'language': 'en',
        },
      );
      if (response.data['status'] == 'OK') {
        final predictions = response.data['predictions'] as List;
        suggestions.value = predictions
            .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        suggestions.clear();
      }
    } catch (e) {
      AppLogger.e('Places autocomplete error', e);
      suggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectPlace(PlacePrediction place) async {
    try {
      final response = await _http.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': place.placeId,
          'key': AppConfig.googleMapsApiKey,
          'fields': 'geometry,name,formatted_address,address_components',
          'language': 'en',
        },
      );
      if (response.data['status'] != 'OK') return;
      final result = response.data['result'] as Map<String, dynamic>;
      final loc = (result['geometry'] as Map)['location'] as Map;
      final components = result['address_components'] as List? ?? [];

      String city = '';
      String county = '';
      String postcode = '';
      for (final c in components) {
        final types = c['types'] as List;
        if (city.isEmpty &&
            (types.contains('locality') || types.contains('postal_town'))) {
          city = c['long_name'] as String;
        }
        if (county.isEmpty && types.contains('country')) {
          county = c['long_name'] as String;
        }
        if (postcode.isEmpty && types.contains('postal_code')) {
          postcode = c['long_name'] as String;
        }
      }

      final address = place.secondaryText.isNotEmpty
          ? place.secondaryText
          : result['formatted_address'] as String? ?? '';
      Get.back(result: {
        'name': place.mainText,
        'address': address,
        'city': city,
        'county': county,
        'postcode': postcode,
        'lat': (loc['lat'] as num).toDouble(),
        'lng': (loc['lng'] as num).toDouble(),
      });
    } catch (e) {
      AppLogger.e('Place details error', e);
    }
  }

  void clearQuery() {
    searchController.clear();
    suggestions.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

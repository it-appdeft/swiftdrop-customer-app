import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:swiftdrop_customer_app/export.dart';
import '../../home/controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import 'delivery_address_controller.dart' show PlacePrediction;

class AddressController extends BaseController {
  final AddressRepository _repo;
  AddressController(this._repo);

  final queryController = TextEditingController();
  final searchFocusNode = FocusNode();

  final RxBool isSearchActive = false.obs;
  final RxList<PlacePrediction> placeSuggestions = <PlacePrediction>[].obs;
  final RxBool isSearchingPlaces = false.obs;

  final RxList<AddressModel> savedAddresses = <AddressModel>[].obs;
  final RxBool hasMore = false.obs;
  final RxBool isSaving = false.obs;

  int _page = 1;
  String? _editingAddressId;
  Timer? _debounce;

  final _http = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Address Details Form
  final additionalDetailsController = TextEditingController();
  final postcodeController = TextEditingController();
  final instructionsController = TextEditingController();
  final otherLabelController = TextEditingController();

  final RxString selectedAddressType = 'Home'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
    searchFocusNode.addListener(_onFocusChanged);
    queryController.addListener(_onQueryChanged);
  }

  void _onFocusChanged() {
    isSearchActive.value = searchFocusNode.hasFocus || queryController.text.isNotEmpty;
  }

  void _onQueryChanged() {
    final text = queryController.text;
    isSearchActive.value = searchFocusNode.hasFocus || text.isNotEmpty;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      placeSuggestions.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _fetchSuggestions(text.trim()));
  }

  Future<void> _fetchSuggestions(String q) async {
    if (q.isEmpty) return;
    isSearchingPlaces.value = true;
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
        placeSuggestions.value = predictions
            .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        placeSuggestions.clear();
      }
    } catch (e) {
      AppLogger.e('Places autocomplete error', e);
      placeSuggestions.clear();
    } finally {
      isSearchingPlaces.value = false;
    }
  }

  Future<void> selectPlace(PlacePrediction place) async {
    searchFocusNode.unfocus();
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
      if (kDebugMode) {
        print('--- PLACE DETAILS RESPONSE START ---');
        print(response.data);
        print('--- PLACE DETAILS RESPONSE END ---');
      }

      if (response.data['status'] != 'OK') return;
      final result = response.data['result'] as Map<String, dynamic>;
      final loc = (result['geometry'] as Map)['location'] as Map;
      final address = place.secondaryText.isNotEmpty
          ? place.secondaryText
          : result['formatted_address'] as String? ?? '';

      String city = '';
      String country = '';
      String postcode = '';
      final components = result['address_components'] as List? ?? [];
      for (final comp in components) {
        final types = (comp['types'] as List).cast<String>();
        final longName = comp['long_name'] as String? ?? '';
        if (city.isEmpty &&
            (types.contains('postal_town') || types.contains('locality'))) {
          city = longName;
        }
        if (types.contains('country')) {
          country = longName;
        }
        if (postcode.isEmpty && types.contains('postal_code')) {
          postcode = longName;
        }
      }

      // Fallbacks for City
      if (city.isEmpty) {
        for (final comp in components) {
          final types = (comp['types'] as List).cast<String>();
          if (types.contains('sublocality_level_1') || types.contains('neighborhood')) {
            city = comp['long_name'] as String? ?? '';
            break;
          }
        }
      }
      if (city.isEmpty) {
        for (final comp in components) {
          final types = (comp['types'] as List).cast<String>();
          if (types.contains('administrative_area_level_2')) {
            city = comp['long_name'] as String? ?? '';
            break;
          }
        }
      }

      if (kDebugMode) {
        print('EXTRACTED DATA FROM SEARCH:');
        print('Name: ${place.mainText}');
        print('City: $city');
        print('Country: $country');
        print('Postcode: $postcode');
      }

      clearSearch();
      startAdd();
      Get.toNamed(AppRoutes.mapPicker, arguments: {
        'lat': (loc['lat'] as num).toDouble(),
        'lng': (loc['lng'] as num).toDouble(),
        'name': place.mainText,
        'address': address,
        'city': city,
        'county': country,
        'postcode': postcode,
      });
    } catch (e) {
      AppLogger.e('Place details error', e);
    }
  }

  void clearSearch() {
    queryController.clear();
    placeSuggestions.clear();
    isSearchActive.value = false;
    searchFocusNode.unfocus();
  }

  Future<void> loadAddresses() async {
    _page = 1;
    await runAsync(() async {
      final result = await _repo.getAddresses(page: _page);
      if (result.data != null) {
        final list = (result.data!['addresses'] as List? ?? [])
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
        savedAddresses.value = list;
        _updateHasMore(result.data!['meta']);
      }
    });
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      _page++;
      final result = await _repo.getAddresses(page: _page);
      if (result.data != null) {
        final list = (result.data!['addresses'] as List? ?? [])
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
        savedAddresses.addAll(list);
        _updateHasMore(result.data!['meta']);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _updateHasMore(dynamic meta) {
    if (meta == null) {
      hasMore.value = false;
      return;
    }
    hasMore.value = meta['next_page_url'] != null;
  }

  void setAddressType(String type) => selectedAddressType.value = type;

  void prefillPostcodeIfAdding(String postcode) {
    if (_editingAddressId == null && postcodeController.text.isEmpty) {
      postcodeController.text = postcode;
    }
  }

  void startAdd() {
    _editingAddressId = null;
    selectedAddressType.value = 'Home';
    additionalDetailsController.clear();
    postcodeController.clear();
    instructionsController.clear();
    otherLabelController.clear();
  }

  void startEdit(AddressModel address) {
    _editingAddressId = address.id;
    if (address.label == 'Home' || address.label == 'Work') {
      selectedAddressType.value = address.label;
      otherLabelController.clear();
    } else {
      selectedAddressType.value = 'Others';
      otherLabelController.text = address.label;
    }
    additionalDetailsController.text = address.addressLine2 ?? '';
    postcodeController.text = address.postcode;
    instructionsController.text = address.deliveryInstructions ?? '';
  }

  Future<void> selectAddress(String id) async {
    AppOverlayLoader.show();
    final result = await _repo.selectAddress(id);
    AppOverlayLoader.hide();

    if (!result.success) {
      AppUtils.showError(result.message.isNotEmpty ? result.message : 'Failed to select address');
      return;
    }

    savedAddresses.value = savedAddresses.map((a) => a.copyWith(isSelected: a.id == id)).toList();

    try {
      final selected = savedAddresses.firstWhere((a) => a.id == id);
      await AuthService.to.saveSelectedAddress(selected);
    } catch (_) {}

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  Future<void> deleteAddress(String id) async {
    await _repo.deleteAddress(id);
    savedAddresses.removeWhere((a) => a.id == id);
  }

  Future<void> saveAddress({
    required String addressLine1,
    required String city,
    required String county,
    required double lat,
    required double lng,
  }) async {
    if (additionalDetailsController.text.trim().isEmpty) {
      AppUtils.showError('Please enter additional details');
      return;
    }
    if (postcodeController.text.trim().isEmpty) {
      AppUtils.showError('Please enter postcode');
      return;
    }
    if (selectedAddressType.value == 'Others' &&
        otherLabelController.text.trim().isEmpty) {
      AppUtils.showError('Please enter a label');
      return;
    }

    isSaving.value = true;
    try {
      final label = selectedAddressType.value == 'Others'
          ? otherLabelController.text.trim()
          : selectedAddressType.value;

      final editId = _editingAddressId;
      late final ApiResponse<dynamic> result;

      if (editId != null) {
        result = await _repo.updateAddress(
          id: editId,
          label: label,
          addressLine1: addressLine1,
          addressLine2: additionalDetailsController.text.trim(),
          city: city,
          county: county,
          postcode: postcodeController.text.trim(),
          lat: lat,
          lng: lng,
          deliveryInstructions: instructionsController.text.trim(),
        );
      } else {
        result = await _repo.saveAddress(
          label: label,
          addressLine1: addressLine1,
          addressLine2: additionalDetailsController.text.trim(),
          city: city,
          county: county,
          postcode: postcodeController.text.trim(),
          lat: lat,
          lng: lng,
          deliveryInstructions: instructionsController.text.trim(),
        );
      }

      if (!result.success) {
        AppUtils.showError(result.message.isNotEmpty ? result.message : 'Failed to save address');
        return;
      }

      final isNewAddress = _editingAddressId == null;
      _editingAddressId = null;
      await loadAddresses();

      try {
        final home = Get.find<HomeController>();
        final display = [addressLine1, city].where((s) => s.isNotEmpty).join(', ');
        if (display.isNotEmpty) home.currentAddress.value = display;
      } catch (_) {}

      if (isNewAddress && result.data != null) {
        try {
          final newAddr = AddressModel.fromJson(result.data as Map<String, dynamic>);
          await selectAddress(newAddr.id);
        } catch (e) {
          AppLogger.e('Error selecting new address', e);
        }
      }

      if (Get.isRegistered<CartController>()) {
        Get.until((route) => route.settings.name == AppRoutes.cart || route.isFirst);
      } else if (editId != null) {
        Get.back();
      } else {
        Get.until((route) => route.settings.name == AppRoutes.address || route.isFirst);
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchFocusNode.removeListener(_onFocusChanged);
    queryController.removeListener(_onQueryChanged);
    searchFocusNode.dispose();
    super.onClose();
  }
}

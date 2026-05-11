import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/local/app_data.dart';
import '../../../base/base_controller.dart';

class HomeController extends BaseController {
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> restaurants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRestaurants = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    searchController.addListener(_onSearchChanged);
  }

  void _loadData() {
    categories.value = AppData.categories;
    restaurants.value = AppData.featuredRestaurants;
    filteredRestaurants.value = AppData.featuredRestaurants;
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase().trim();
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredRestaurants.value = restaurants;
    } else {
      filteredRestaurants.value = restaurants.where((r) {
        return (r['name'] as String).toLowerCase().contains(query) ||
            (r['category'] as String).toLowerCase().contains(query);
      }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    filteredRestaurants.value = restaurants;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

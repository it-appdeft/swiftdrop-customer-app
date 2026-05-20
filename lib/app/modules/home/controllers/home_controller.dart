import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  HomeController(this._repo);

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

  Future<void> _loadData() async {
    await runAsync(() async {
      final catResult = await _repo.getCategories();
      if (catResult.success && catResult.data != null) {
        categories.value = catResult.data!;
      }
      final restResult = await _repo.getFeaturedRestaurants();
      if (restResult.success && restResult.data != null) {
        restaurants.value = restResult.data!;
        filteredRestaurants.value = restResult.data!;
      }
    });
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
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}

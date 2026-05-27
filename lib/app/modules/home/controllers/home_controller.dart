import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final RxList<FoodItemModel> foodItems = <FoodItemModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxString currentAddress = 'Select Location'.obs;
  final RxInt currentBannerPage = 0.obs;
  late final PageController bannerPageController;

  List<RestaurantModel> get topPicks => restaurants.take(5).toList();

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController();
    bannerPageController.addListener(_onBannerPage);
    _loadDashboard();
  }

  void _onBannerPage() {
    if (bannerPageController.page != null) {
      currentBannerPage.value = bannerPageController.page!.round();
    }
  }

  Future<void> _loadDashboard() async {
    await runAsync(() async {
      final result = await _repo.getDashboard();
      if (result.success && result.data != null) {
        final data = result.data!;
        foodItems.value = data.foodItems;
        restaurants.value = data.restaurants;
        if (data.address != null) {
          final addr = data.address!;
          currentAddress.value = '${addr.addressLine1}, ${addr.city}';
        }
      }
    });
  }

  Future<void> refresh() => _loadDashboard();

  @override
  void onClose() {
    bannerPageController.removeListener(_onBannerPage);
    bannerPageController.dispose();
    super.onClose();
  }
}

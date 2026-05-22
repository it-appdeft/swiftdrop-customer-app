import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> restaurants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRestaurants = <Map<String, dynamic>>[].obs;

  final RxInt currentBannerPage = 1.obs;
  late final PageController bannerPageController;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController(initialPage: 1);
    bannerPageController.addListener(_onBannerPage);
    _loadData();
  }

  void _onBannerPage() {
    if (bannerPageController.page != null) {
      currentBannerPage.value = bannerPageController.page!.round();
    }
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

  @override
  void onClose() {
    bannerPageController.removeListener(_onBannerPage);
    bannerPageController.dispose();
    super.onClose();
  }
}

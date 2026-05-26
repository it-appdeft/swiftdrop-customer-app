import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> restaurants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRestaurants = <Map<String, dynamic>>[].obs;

  final RxInt currentBannerPage = 1.obs;
  late final PageController bannerPageController;

  final RxString currentAddress = 'Select Location'.obs;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController(initialPage: 1);
    bannerPageController.addListener(_onBannerPage);
    _getCurrentLocation();
    _loadData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        currentAddress.value = 'West Coker, Yelovil, UK'; 
      }
    } catch (e) {
      AppLogger.e('Error getting location: $e');
    }
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

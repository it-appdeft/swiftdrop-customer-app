import 'package:swiftdrop_customer_app/export.dart';

class RestaurantDetailController extends BaseController {
  final restaurant = {}.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilterIndex = 2.obs;
  final RxBool isVegSelected = false.obs;
  final RxBool isNonVegSelected = false.obs;
  final RxBool isRatingsSelected = false.obs;
  final RxBool isBestsellerSelected = false.obs;
  final RxBool showCartFloatingBar = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      restaurant.value = Get.arguments;
    } else {
      // Mock data if no arguments
      restaurant.value = {
        'name': 'The Marble Grill',
        'image': 'assets/images/onbording1.png',
        'rating': 4.5,
        'reviews': '200K+',
        'time': '25-35',
        'category': 'Steakhouse • Premium Pizza',
        'dishes': [
          {
            'name': 'Margherita Ultimate Cheese Pizza',
            'price': '8.23',
            'rating': 4.8,
            'image': 'assets/images/onbording3.png',
          },
          {
            'name': 'Margherita Pizza Giant Slice',
            'price': '8.23',
            'rating': 4.0,
            'image': 'assets/images/onbording1.png',
          },
          {
            'name': 'Sweet Corn Pizza Regular',
            'price': '8.23',
            'rating': 4.8,
            'image': 'assets/images/onbording2.png',
          },
          {
            'name': 'Onions Thin Crust Pizza',
            'price': '8.23',
            'rating': 4.2,
            'image': 'assets/images/onbording1.png',
          },
        ],
        'recommended': [
          {
            'name': 'Sweet Corn Pizza Regular',
            'price': '8.00',
            'rating': 4.5,
            'image': 'assets/images/onbording2.png',
          },
          {
            'name': 'Onions Thin Crust Pizza',
            'price': '4.23',
            'rating': 4.6,
            'image': 'assets/images/onbording1.png',
          },
          {
            'name': 'Margherita Pizza Giant Slice',
            'price': '4.01',
            'rating': 4.5,
            'image': 'assets/images/onbording1.png',
          },
        ]
      };
    }
  }
}

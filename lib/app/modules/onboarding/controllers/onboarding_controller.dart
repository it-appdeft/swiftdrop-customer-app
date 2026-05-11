import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> pages = [
    {
      'titleBefore': 'Fast Delivery\nOf ',
      'titleHighlight': 'Delicious',
      'titleAfter': ' Food',
      // 'subtitle': 'Order your favourite meals from top restaurants and get them delivered straight to your door.',
      'subtitle': 'Order your favorite meals from top restaurants and get them delivered Fast',
      'image': 'assets/images/onbording1.png',
    },
    {
      'titleBefore': 'Great Food From\n',
      'titleHighlight': 'Top Restaurants',
      'titleAfter': '',
      // 'subtitle': 'Choose from a wide variety of cuisines and enjoy restaurant-quality food from the comfort of home.',
      'subtitle': 'Choose from a wide variety of cuisines and enjoy restaurant quality food',
      'image': 'assets/images/onbording2.png',
    },
    {
      'titleBefore': 'Track Your Order\nIn ',
      'titleHighlight': 'Real-Time',
      'titleAfter': '',
      // 'subtitle': 'Follow your delivery on the map and receive real-time updates every step of the way.',
      'subtitle': 'Track your order in real-time and get updates every step of the way',
      'image': 'assets/images/onbording3.png',
    },
  ];

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void completeOnboarding() {
    StorageService.to.write(StorageKeys.onboardingCompleted, true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

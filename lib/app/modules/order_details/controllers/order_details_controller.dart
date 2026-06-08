import 'package:swiftdrop_customer_app/export.dart';

class OrderDetailsController extends GetxController {
  // Static data for now as requested
  final orderId = "#SWD12345".obs;
  final deliveredOn = "April 24, 6:42 PM".obs;
  
  final deliveryAddress = "4521 Emerald Valley, Block B, Suite 104, Green Park, CA 90210".obs;
  final deliveryPartner = "James Bride".obs;
  
  final restaurantName = "The Marble Grill".obs;
  final restaurantAddress = "West Coker, Yelovil, UK".obs;

  // Mock items
  final items = <Map<String, dynamic>>[
    {
      "name": "Margherita Pizza",
      "subtitle": "Giant Slice x1",
      "price": "£8.23",
      "image": "https://via.placeholder.com/150",
      "rating": 4.0,
    },
    {
      "name": "Sweet Corn Pizza",
      "subtitle": "Regular x1",
      "price": "£8.02",
      "image": "https://via.placeholder.com/150",
      "rating": 3.0,
    },
  ].obs;

  final partnerRating = 1.0.obs;

  final itemTotal = "£16.25".obs;
  final deliveryFee = "£2.20".obs;
  final taxesAndCharges = "£1.20".obs;
  final toPay = "£19.65".obs;
  
  final paymentMethod = "Visa ***3432".obs;
  final paymentStatus = "Paid".obs;

  void onReorder() {
    // Implement reorder logic
    AppUtils.showSuccess('Reordering...');
  }
}

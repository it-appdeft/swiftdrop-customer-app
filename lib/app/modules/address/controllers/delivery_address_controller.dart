import 'package:swiftdrop_customer_app/export.dart';

class DeliveryAddressController extends GetxController {
  final searchController = TextEditingController();
  final RxString query = ''.obs;
  
  final RxList<Map<String, String>> suggestions = <Map<String, String>>[
    {
      'title': 'West Coker',
      'subtitle': 'Yeovil, UK',
    },
    {
      'title': 'West Coker Road',
      'subtitle': 'Yeovil, UK',
    },
    {
      'title': 'West Coker Scout Group',
      'subtitle': 'Halves Lane, West UK',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      query.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

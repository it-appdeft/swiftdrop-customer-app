import 'package:swiftdrop_customer_app/export.dart';

class AddressController extends BaseController {
  final queryController = TextEditingController();
  final RxList<AddressModel> savedAddresses = <AddressModel>[
    AddressModel(
      id: '1',
      label: 'Home',
      address: 'West Coker Midtown, West Yelovil UK',
      isSelected: true,
    ),
    AddressModel(
      id: '2',
      label: 'Work',
      address: '68, Broadway, Midtown, West Yelovil London',
    ),
    AddressModel(
      id: '3',
      label: 'Office',
      address: '12,Park Street, Central Park, West Yelovil London',
    ),
  ].obs;

  final RxList<AddressModel> moreAddresses = <AddressModel>[
    AddressModel(
      id: '4',
      label: 'Gym',
      address: '55, Fitness Lane, West Yelovil UK',
    ),
    AddressModel(
      id: '5',
      label: 'Parents',
      address: '101, Family Road, West Yelovil UK',
    ),
  ].obs;

  final RxBool showAll = false.obs;

  // Address Details Form
  final additionalDetailsController = TextEditingController();
  final postcodeController = TextEditingController();
  final instructionsController = TextEditingController();
  final otherLabelController = TextEditingController();

  final RxString selectedAddressType = 'Home'.obs; // Home, Work, Others

  void setAddressType(String type) {
    selectedAddressType.value = type;
  }

  void toggleViewAll() {
    showAll.value = !showAll.value;
  }

  void selectAddress(String id) {
    savedAddresses.value = savedAddresses.map((addr) {
      return addr.copyWith(isSelected: addr.id == id);
    }).toList();
  }

  void deleteAddress(String id) {
    savedAddresses.removeWhere((addr) => addr.id == id);
    moreAddresses.removeWhere((addr) => addr.id == id);
  }

  List<AddressModel> get displayedAddresses {
    if (showAll.value) {
      return [...savedAddresses, ...moreAddresses];
    }
    return savedAddresses;
  }
}

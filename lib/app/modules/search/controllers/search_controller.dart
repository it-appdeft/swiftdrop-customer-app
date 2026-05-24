import 'package:swiftdrop_customer_app/export.dart';

class SearchTabController extends BaseController {
  final queryController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<String> recentSearches = <String>[
    'Burgers',
    'Wagamama',
    'Pizza',
    'Pret A Manger',
  ].obs;

  final RxInt selectedTabIndex = 0.obs; // 0: Restaurants, 1: Dishes
  final RxSet<String> activeFilters = <String>{}.obs;

  // Mock data
  final RxList<Map<String, dynamic>> restaurantResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> dishResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    queryController.addListener(_onQuery);
  }

  void _onQuery() {
    searchQuery.value = queryController.text.trim();
    if (searchQuery.value.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    // Mocking search results
    restaurantResults.value = [
      {
        'name': 'The Marble Grill',
        'image': 'assets/images/onbording1.png',
        'rating': 4.5,
        'time': '20-30 min',
        'distance': '4.9 mi',
        'offer': '60% OFF select items',
      },
      {
        'name': 'My World Pizza',
        'image': 'assets/images/onbording2.png',
        'rating': 4.6,
        'time': '20-30 min',
        'distance': '5.9 mi',
        'offer': '20% OFF select items',
      },
    ];

    dishResults.value = [
      {
        'name': 'The Marble Grill',
        'time': '20-30 min',
        'distance': '4.9 mi',
        'dishes': [
          {
            'name': 'Margherita Ultimate Cheese Pizza',
            'price': '8.23',
            'rating': 4.8,
            'image': 'assets/images/onbording3.png',
          },
          {
            'name': 'Pepperoni Feast',
            'price': '9.50',
            'rating': 4.7,
            'image': 'assets/images/onbording1.png',
          },
        ],
      },
      {
        'name': 'My World Pizza',
        'time': '20-30 min',
        'distance': '5.9 mi',
        'dishes': [
          {
            'name': 'Sweet Corn Pizza Regular',
            'price': '8.23',
            'rating': 4.8,
            'image': 'assets/images/onbording2.png',
          },
        ],
      },
    ];
  }

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
  }

  void onSubmit(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    if (!recentSearches.contains(t)) {
      recentSearches.insert(0, t);
      if (recentSearches.length > 8) recentSearches.removeLast();
    }
  }

  void tapRecent(String q) {
    queryController.text = q;
    queryController.selection = TextSelection.collapsed(offset: q.length);
  }

  void removeRecent(String q) => recentSearches.remove(q);
  void clearRecent() => recentSearches.clear();
  void clearQuery() => queryController.clear();

  @override
  void onClose() {
    queryController.removeListener(_onQuery);
    super.onClose();
  }
}

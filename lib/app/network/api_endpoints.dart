class ApiEndpoints {
  ApiEndpoints._();

  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register/customer';

  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String updateAvatar = '/user/profile/avatar';

  static const String customerProfile = '/customer/profile';
  static const String customerProfileDeleteInitiate =
      '/customer/profile/delete/initiate';
  static const String deletionReasons = '/deletion-reasons';

  static const String activeOrders = '/user/orders/active';
  static const String orderHistory = '/user/orders/history';
  static const String orderDetail = '/user/orders';
  static const String placeOrder = '/user/orders/place';
  static const String cancelOrder = '/user/orders/cancel';

  static const String walletBalance = '/user/wallet/balance';
  static const String transactions = '/user/transactions';
  static const String addFunds = '/user/wallet/add-funds';
  static const String withdraw = '/user/wallet/withdraw';

  static const String notifications = '/user/notifications';
  static const String markNotificationRead = '/user/notifications/read';

  static const String savedAddresses = '/user/addresses';
  static const String addAddress = '/user/addresses/add';
  static const String deleteAddress = '/user/addresses/delete';

  static const String customerCart = '/customer/cart';
  static String customerCartItem(int id) => '/customer/cart/items/$id';
  static const String customerDashboard = '/customer/dashboard';
  static const String customerSearch = '/customer/search';
  static String customerRestaurantDetail(int id) => '/customer/restaurants/$id';
  static const String restaurants = '/restaurants';
  static const String restaurantDetail = '/restaurants';
  static const String categories = '/categories';
  static const String searchRestaurants = '/restaurants/search';
}

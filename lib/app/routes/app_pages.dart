import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../middleware/connectivity_middleware.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/register_steps_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/verification_pending_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/cart/views/coupons_view.dart';
import '../modules/cart/views/order_success_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/delete_account_confirmation_view.dart';
import '../modules/edit_profile/views/delete_account_reason_view.dart';
import '../modules/edit_profile/views/edit_entry_view.dart';
import '../modules/edit_profile/views/edit_otp_view.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/order_history/bindings/order_history_binding.dart';
import '../modules/order_history/views/order_history_view.dart';
import '../modules/order_tracking/bindings/order_tracking_binding.dart';
import '../modules/order_tracking/views/order_tracking_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/restaurant_detail/bindings/restaurant_detail_binding.dart';
import '../modules/restaurant_detail/views/restaurant_detail_view.dart';
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.registerSteps,
      page: () => const RegisterStepsView(),
    ),
    GetPage(
      name: AppRoutes.verificationPending,
      page: () => const VerificationPendingView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderTracking,
      page: () => const OrderTrackingView(),
      binding: OrderTrackingBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.changePhone,
      page: () => const EditEntryView(flow: EditEntryFlow.phone),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verifyExisting,
      page: () => const EditOtpView(flow: EditOtpFlow.existing),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verifyNewPhone,
      page: () => const EditOtpView(flow: EditOtpFlow.newPhone),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.changeEmail,
      page: () => const EditEntryView(flow: EditEntryFlow.email),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const EditOtpView(flow: EditOtpFlow.email),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verifyAccount,
      page: () => const EditOtpView(flow: EditOtpFlow.account),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verifyAccountDeletion,
      page: () => const EditOtpView(flow: EditOtpFlow.deleteAccount),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.deleteAccountReason,
      page: () => const DeleteAccountReasonView(),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.deleteAccountConfirmation,
      page: () => const DeleteAccountConfirmationView(),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.restaurantDetail,
      page: () => const RestaurantDetailView(),
      binding: RestaurantDetailBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.coupons,
      page: () => const CouponsView(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware(), ConnectivityMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const OrderSuccessView(),
    ),
  ];
}

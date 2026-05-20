# SwiftDrop User App — CLAUDE.md

## WHAT THIS PROJECT IS
SwiftDrop User App — the customer-facing companion to SwiftDrop Driver App. UK-based delivery platform (similar to Deliveroo/Uber Eats customer side). No real APIs yet — UI-only demo phase. All HTTP calls fail gracefully and fall back to local data in `lib/data/local/app_data.dart`. OTP login uses hardcoded code `9999`. UK market only.

---

## ABSOLUTE RULES — NEVER BREAK THESE
- Architecture: **GetX MVC, feature-first modular**. Every module has `bindings/`, `controllers/`, `views/` folders.
- State: **GetX only** (`Obx`, `GetxController`, `GetxService`). No Bloc, Provider, Riverpod, setState for business logic.
- Routing: **Named routes only** via `Get.toNamed`, `Get.offAllNamed`. All routes registered in `AppPages`.
- DI: **`Get.put` for controllers that own lifecycle (splash). `Get.lazyPut` for all others.**
- Splash binding MUST use `Get.put` (not `Get.lazyPut`) — the splash view does not reference `controller` in build(), so lazyPut never instantiates it.
- `Obx` must only wrap widgets that read `.value` from an `Rx` observable. Never wrap plain getters in `Obx`.
- No `Spacer()` inside `Column` when the view has a scrollable body or keyboard interaction — use `SingleChildScrollView` + fixed `SizedBox` gaps instead.
- All views with text inputs MUST be wrapped in `SingleChildScrollView`.
- Currency: **£ (GBP)** everywhere. Never ₹, $, €.
- Phone: **UK mobile format** `07xxx xxxxxx` (11 digits, starts with 07). Display as `+44 7xxx xxxxxx`.
- Country code picker shows: 🇬🇧 +44.
- No comments unless WHY is non-obvious. No docstrings. No TODO comments.
- No mock/demo labels anywhere in code, class names, or strings.

---

## TECH STACK — EXACT PACKAGES

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1
  dio: ^5.4.3
  firebase_core: ^3.1.0
  firebase_messaging: ^15.0.2
  flutter_local_notifications: ^17.1.2
  flutter_dotenv: ^5.1.0
  connectivity_plus: ^6.0.3
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  geolocator: ^12.0.0
  google_maps_flutter: ^2.7.0
  permission_handler: ^11.3.1
  logger: ^2.3.0
  intl: ^0.19.0
  google_fonts: ^6.2.1
  country_picker: ^2.0.27
  cupertino_icons: ^1.0.8
```

Font: **Inter** via `google_fonts` package.
State: GetX `^4.6.6`
Storage: GetStorage (local, persistent, no SQLite)
HTTP: Dio with 3 interceptors (auth, logging, retry)
Maps: google_maps_flutter

---

## FOLDER STRUCTURE

```
lib/
├── app/
│   ├── base/
│   │   └── base_controller.dart         ← all controllers extend this
│   ├── bindings/
│   │   └── initial_binding.dart         ← registers 4 permanent services at startup
│   ├── config/
│   │   └── app_config.dart              ← reads .env via flutter_dotenv
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── middleware/
│   │   ├── auth_middleware.dart
│   │   ├── connectivity_middleware.dart
│   │   └── notification_middleware.dart
│   ├── modules/                         ← feature modules, each has bindings/controllers/views
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/                        ← login, otp, register, register_steps, verification_pending
│   │   ├── dashboard/                   ← shell with bottom nav (IndexedStack 5 tabs)
│   │   ├── home/                        ← browse, search, categories, restaurants
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── order_tracking/
│   │   ├── order_history/
│   │   ├── wallet/
│   │   ├── notifications/
│   │   ├── profile/
│   │   ├── settings/
│   ├── network/
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── retry_interceptor.dart
│   │   ├── api_endpoints.dart
│   │   └── dio_client.dart
│   ├── routes/
│   │   ├── app_routes.dart              ← static const String route names
│   │   └── app_pages.dart               ← GetPage list
│   ├── services/
│   │   ├── auth_service.dart            ← GetxService, permanent
│   │   ├── connectivity_service.dart    ← GetxService, permanent
│   │   ├── notification_service.dart    ← GetxService, permanent, Firebase optional
│   │   └── storage_service.dart         ← GetxService, permanent, wraps GetStorage
│   ├── themes/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   ├── app_decorations.dart
│   │   ├── app_radius.dart
│   │   └── app_shadows.dart
│   ├── utils/
│   │   ├── app_logger.dart
│   │   ├── app_utils.dart               ← formatCurrency(£), isValidPhone(UK), showError/showSuccess
│   │   └── responsive.dart
│   └── widgets/                         ← shared UI components
│       ├── app_button.dart
│       ├── app_loader.dart
│       ├── app_text_field.dart
│       ├── connectivity_widget.dart
│       ├── empty_state_widget.dart
│       ├── error_state_widget.dart
│       ├── info_row.dart
│       ├── pagination_list.dart
│       ├── section_header.dart
│       ├── shimmer_widgets.dart
│       └── status_badge.dart
├── data/
│   ├── local/
│   │   └── app_data.dart                ← class AppData, all fallback data
│   ├── models/
│   │   ├── api_response.dart
│   │   ├── user_model.dart
│   │   ├── order_model.dart
│   │   ├── transaction_model.dart
│   │   └── notification_model.dart
│   └── repositories/                    ← all have try/catch fallback to AppData
│       ├── auth_repository.dart
│       ├── order_repository.dart
│       ├── earnings_repository.dart
│       └── notification_repository.dart
├── export.dart                           ← barrel file, imported by main.dart
└── main.dart
```

---

## DESIGN SYSTEM

### Brand Colors (`lib/app/themes/app_colors.dart`)
```dart
// Primary — Green
primary        = Color(0xFF1BC27D)
primaryDark    = Color(0xFF169B64)
primaryLight   = Color(0xFF32C88A)
primaryFaded   = Color(0xFF8DE1BE)

// Dark theme surfaces
darkBackground      = Color(0xFF121212)   ← scaffold bg
darkSurface         = Color(0xFF1E1E2E)   ← cards, appbar
darkSurfaceElevated = Color(0xFF252535)
darkBorder          = Color(0xFF2E3A47)
darkInputBg         = Color(0xFF1A2535)

// Navy muted (for secondary text, icons)
navyMuted200 = Color(0xFF85929D)
navyMuted300 = Color(0xFF6D7C89)
navyMuted400 = Color(0xFF546675)
navyMuted600 = Color(0xFF233A4E)

// Semantic aliases (use these in code)
background    = darkBackground
surface       = darkSurface
border        = darkBorder
textPrimary   = Color(0xFFF5F6EE)   ← near-white
textSecondary = Color(0xFF85929D)   ← navyMuted200
textHint      = Color(0xFF6D7C89)   ← navyMuted300

// Semantic state
success     = Color(0xFF1BC27D)
warning     = Color(0xFFF5A623)
error       = Color(0xFFDC3545)
white       = Color(0xFFFFFFFF)
offWhite    = Color(0xFFF6F8FA)
buttonLabel = Color(0xFFFEFEFD)   ← used for button text (not pure white)

// Light-surface — used on auth screens (login, OTP, register — white background)
lightSurfaceDarkText  = Color(0xFF0B243A)
lightSurfaceText      = Color(0xFF071623)
lightSurfaceVerified  = Color(0xFF10744B)
lightInputText        = Color(0xFF0F191F)
lightSurfaceHeading   = Color(0xFF3C4042)
lightSurfaceLabel     = Color(0xFF595D70)
lightSurfaceSubtitle  = Color(0xFF868AA5)
lightSurfaceDisabled  = Color(0xFFE1E2E3)
lightSurfaceBorder    = Color(0xFFF2F2E9)
lightSurfaceHint      = Color(0xFFADB5BD)
lightOtpBoxBg         = Color(0xFFEDEEF1)   ← OTP box empty state
lightOtpFocusBorder   = Color(0xFF198754)   ← OTP box focused/filled border
```

**Auth screens use a white/light surface design** (not dark theme). All `auth/` views set `backgroundColor: AppColors.white` and use `lightSurface*` colors. The dark `otpBox`/`otpBoxFocused` decorations in `AppDecorations` are reserved for post-auth screens.

### Typography (`lib/app/themes/app_text_styles.dart`)
Font: **Inter** (Google Fonts). All styles via `GoogleFonts.inter(...)`.
```
h1 → 48px / w700    h2 → 40px / w700    h3 → 32px / w700
h4 → 28px / w600    h5 → 24px / w600    h6 → 20px / w600

pLarge       → 18px / w400    pLargeSemiBold  → 18px / w600
pMedium      → 16px / w400    pMediumSemiBold → 16px / w600    pMediumBold → 16px / w700
pSmall       → 14px / w400    pSmallMedium    → 14px / w500    pSmallSemiBold → 14px / w600
pXSmall      → 12px / w400    pXSmallMedium   → 12px / w500    pXSmallSemiBold → 12px / w600

label    → 12px / w600 / letterSpacing 0.5
caption  → 11px / color textHint
amount   → 22px / w700 / color success (green)
amountLg → 32px / w700 / color success
button   → 16px / w600 / color buttonLabel
```
Default color for all text styles: `AppColors.textPrimary` (near-white).

### Dimensions (`lib/app/themes/app_dimensions.dart`)
**4px grid system:**
```
sp4=4  sp8=8  sp12=12  sp16=16  sp20=20  sp24=24  sp32=32  sp40=40

Padding: paddingXs=8  paddingXsm=10  paddingSm=12  paddingMd=16  paddingLg=20  paddingXl=24
Gaps:    gapXs=4      gapSm=8        gapMd=12       gapLg=16      gapXl=24

Border radius:
  radiusXs=4  radiusSm=8  radiusSmd=10  radiusMd=12  radiusLg=16  radiusXl=20  radiusXxl=24  radiusFull=100

AppRadius helpers (BorderRadius objects in app_radius.dart):
  xs  sm  smd  md  lg  xl  xxl  full
  topLg  topXl  topXxl  ← top-corners-only variants for bottom sheets

Components:
  inputHeight=44    buttonHeight=48    buttonHeightLg=56
  bottomNavHeight=64   appBarHeight=56   otpBoxSize=48

Icons: iconXs=14  iconSm=18  iconMd=24  iconLg=32  iconXl=48
Avatar: avatarSm=32  avatarMd=48  avatarLg=72  avatarXl=96
```

### Theme (`lib/app/themes/app_theme.dart`)
- Material 3, dark-first. `AppTheme.darkTheme` is the only theme (both `theme` and `darkTheme` point to it).
- `scaffoldBackgroundColor`: `darkBackground` (#121212)
- AppBar: `darkSurface`, centered title, no elevation
- ElevatedButton: green (#1BC27D), white text, radius 16, height 52, full width
- Input: filled `darkInputBg`, border `darkBorder`, focused border green 1.5px
- Card: `darkSurface`, no elevation, border `darkBorder` 0.5px, radius 12
- BottomNav: `darkSurface`, selected=green, unselected=navyMuted300
- SnackBar: floating, `darkSurfaceElevated`, radius 12

---

## CONSTANTS (`lib/app/constants/app_constants.dart`)
```dart
splashDuration  = 5600    // ms — matches splash animation length
otpResendTimer  = 60      // seconds
snackbarDuration= 3       // seconds
otpLength       = 4       // boxes
phoneMinLength  = 11      // UK: 07xxx xxxxxx
defaultOtp      = '9999'  // hardcoded until real API
paginationLimit = 10
mapDefaultZoom  = 15.0
mapDriverZoom   = 17.0
```

## STORAGE KEYS (`lib/app/constants/storage_keys.dart`)
```dart
authToken               = 'auth_token'
refreshToken            = 'refresh_token'
userData                = 'user_data'
onboardingCompleted     = 'onboarding_completed'
fcmToken                = 'fcm_token'
appSettings             = 'app_settings'
selectedLanguage        = 'selected_language'
isOnlineMode            = 'is_online_mode'            // keep for driver-app compat
lastSyncTime            = 'last_sync_time'
settingPushNotifications = 'setting_push_notifications'
settingOrderUpdates     = 'setting_order_updates'
settingPromotions       = 'setting_promotions'
```

---

## SERVICES (all registered in `InitialBinding` as permanent GetxServices)

### StorageService
- Wraps GetStorage. Keys defined in `StorageKeys`.
- `authToken`, `refreshToken`, `userData` (UserModel JSON), `onboardingCompleted`, `fcmToken`.
- `isLoggedIn`: token != null && not empty.
- `clearAuth()`: removes token + refreshToken + userData.

### AuthService
- `isAuthenticated` → `StorageService.to.isLoggedIn`
- `saveSession(accessToken, refreshToken, user)` → saves to storage, updates `currentUser`
- `logout()` → clears storage, resets DioClient, sets currentUser=null

### ConnectivityService
- `isConnected` (RxBool) — checked in BaseController
- Auto-listens to connectivity changes. Initial check on onInit.

### NotificationService
- Firebase optional. `onInit()` checks `Firebase.apps.isEmpty` first — returns silently if Firebase not configured.
- ENTIRE setup wrapped in try/catch. Logs warning on failure, never crashes.

---

## NETWORK LAYER

### DioClient (`lib/app/network/dio_client.dart`)
- Singleton `DioClient.instance` (Dio object)
- Base URL from `.env` → `AppConfig.baseUrl`
- Interceptors: `AuthInterceptor` (injects token), `LoggingInterceptor`, `RetryInterceptor`
- `DioClient.reset()` called on logout

### Repository pattern
Every repository method wraps HTTP call in try/catch. On any error, returns `AppData` fallback:
```dart
Future<ApiResponse<T>> someMethod() async {
  try {
    final response = await _dio.get(ApiEndpoints.someEndpoint);
    return ApiResponse.fromJson(response.data, (data) => T.fromJson(data));
  } catch (_) {
    return ApiResponse<T>(success: true, message: '', data: AppData.someField);
  }
}
```
`message` is always `''` (empty string) in fallback — never `'demo'` or `'mock'`.

### API Endpoints (driver-side, for reference — user-side will differ)
```
/auth/send-otp          /auth/verify-otp        /auth/refresh-token     /auth/logout
/driver/profile         /driver/orders/active   /driver/orders/history
/driver/orders/accept   /driver/orders/reject   /driver/orders/status
/driver/earnings/summary /driver/transactions   /driver/notifications
```

---

## AUTH FLOW

```
Splash (~5.6s animation) → Onboarding (first launch) → Login → OTP → Dashboard
```

**OTP logic (AuthController.verifyOtp):**
```dart
if (_fullOtp != AppConstants.defaultOtp) {
  AppUtils.showError('Invalid OTP. Please enter the correct code.');
  return;
}
// proceed to save session and navigate to dashboard
```

**Session tokens:** `'sd_access_token'` / `'sd_refresh_token'` (hardcoded strings used in fallback).

**Phone validation (UK):**
```dart
static bool isValidPhone(String phone) =>
    RegExp(r'^07\d{9}$').hasMatch(phone); // 11 digits, starts with 07
```

**Phone display format:**
```dart
final display = raw.startsWith('0') ? '+44 ${raw.substring(1)}' : raw;
// "07700900001" → "+44 7700900001"
```

**Currency format:**
```dart
AppUtils.formatCurrency(amount, symbol: '£') // → "£48.50"
```

---

## BASE CONTROLLER (`lib/app/base/base_controller.dart`)
All controllers extend this.
```dart
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  bool get isConnected => ConnectivityService.to.isConnected.value;

  Future<T?> runAsync<T>(Future<T> Function() operation, {
    bool showLoadingIndicator = true,
    bool handleErrors = true,
  }) async { ... }
}
```
Use `runAsync()` for all async operations in controllers.

---

## ROUTING RULES

### AppRoutes (static const strings)
```dart
splash              = '/splash'
onboarding          = '/onboarding'
login               = '/login'
otp                 = '/otp'
register            = '/register'
registerSteps       = '/register-steps'
verificationPending = '/verification-pending'
dashboard           = '/dashboard'
orderTracking       = '/order-tracking'
orderHistory        = '/order-history'
wallet              = '/wallet'
notifications       = '/notifications'
profile             = '/profile'
settings            = '/settings'
cart                = '/cart'
checkout            = '/checkout'
```

### AppPages rules
- `splash`: **no middleware**. SplashBinding MUST use `Get.put` (not lazyPut).
- `onboarding`, `login`, `otp`, `register`, `registerSteps`, `verificationPending`: **no middleware**.
- `dashboard` and all post-auth routes (`orderTracking`, `orderHistory`, `wallet`, `notifications`, `profile`, `settings`, `cart`, `checkout`): `middlewares: [AuthMiddleware(), ConnectivityMiddleware()]`
- `ConnectivityMiddleware`: shows warning snackbar only, returns null (no hard redirect).
- `AuthMiddleware`: redirects to `/login` if not authenticated.

---

## DATA MODELS

### UserModel (fields)
```
id, name, phone, email?, avatar?, vehicleType?, vehicleNumber?,
rating?, totalDeliveries, isActive, isVerified, isOnline, walletBalance, createdAt?
```
- For User App: `vehicleType`/`vehicleNumber` not relevant but keep field for shared model compat.

### OrderModel (key fields)
```
id, orderNumber, status, pickupAddress, deliveryAddress, items,
totalAmount(£), deliveryFee(£), driverTip(£), distance, estimatedTime,
createdAt, acceptedAt, pickedUpAt, deliveredAt
```
Status values: `'pending'`, `'accepted'`, `'picked_up'`, `'delivered'`, `'cancelled'`

### TransactionModel (key fields)
```
id, type ('credit'/'debit'), amount(£), description, createdAt, status
```

### NotificationModel (key fields)
```
id, title, body, type, data(Map), isRead, createdAt
```

### ApiResponse<T>
```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
}
```

---

## AppData (`lib/data/local/app_data.dart`) — CLASS NAME: `AppData`
No "mock" or "demo" in class names, file names, or variable names.
```dart
class AppData {
  AppData._();
  static final user = UserModel(id: 'user_001', name: 'James Hartley', phone: '07700900001', ...);
  static final List<OrderModel> activeOrders = [...];           // 1 active order
  static final List<OrderModel> orderHistory = [...];           // 3 orders (delivered/cancelled)
  static final Map<String, dynamic> walletSummary = {          // NOT earningsSummary
    'balance': 24.50, 'totalSpent': 348.75, 'totalOrders': 18
  };
  static final List<TransactionModel> transactions = [...];     // 5 transactions
  static final List<NotificationModel> notifications = [...];   // 4 notifications
  static final List<Map<String, dynamic>> savedAddresses = [...]; // Home + Work (London)
  static final List<Map<String, dynamic>> categories = [...];   // 8 food categories
  static final List<Map<String, dynamic>> featuredRestaurants = [...]; // 5 UK restaurants
}
```
UK data: London addresses (EC1V, EC1M, WC2A, E20, E14, WC2H postcodes), UK names, £ amounts, 07700 9xxxxx phones. Restaurants: The Burger Joint, Wagamama, Pret A Manger, Dishoom, Nando's.

---

## .env FILE
```
BASE_URL=https://api.swiftdrop.com
SOCKET_URL=wss://socket.swiftdrop.com
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
FIREBASE_WEB_API_KEY=your_firebase_web_api_key_here
APP_NAME=SwiftDrop
IS_DEBUG=true
API_TIMEOUT=30
```
No DEMO_MODE key.

---

## MAIN.DART PATTERN
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  try { await Firebase.initializeApp(); } catch (_) {}
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const SwiftDropApp());
}

class SwiftDropApp extends StatelessWidget {
  Widget build(BuildContext context) => GetMaterialApp(
    title: AppConfig.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    initialBinding: InitialBinding(),
    initialRoute: AppRoutes.splash,
    getPages: AppPages.routes,
    defaultTransition: Transition.cupertino,
    transitionDuration: const Duration(milliseconds: 280),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: child!,
    ),
  );
}
```

---

## MODULE PATTERN (copy for each feature)

### bindings/feature_binding.dart
```dart
class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeatureRepository>(() => FeatureRepository());
    Get.lazyPut<FeatureController>(() => FeatureController(Get.find()));
  }
}
```

### controllers/feature_controller.dart
```dart
class FeatureController extends BaseController {
  final FeatureRepository _repo;
  FeatureController(this._repo);

  // Rx state
  final items = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    await runAsync(() async {
      final result = await _repo.getItems();
      if (result.success && result.data != null) items.value = result.data!;
    });
  }
}
```

### views/feature_view.dart
```dart
class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: Text('Feature', style: AppTextStyles.h6)),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.hasError.value) return ErrorStateWidget(message: controller.errorMessage.value);
        if (controller.items.isEmpty) return const EmptyStateWidget(message: 'No items yet');
        return ListView.builder(...);
      }),
    );
  }
}
```

---

## UK LOCALISATION CHECKLIST
Every view that handles these must follow:
- [ ] Currency: £ symbol, `AppUtils.formatCurrency(amount, symbol: '£')`
- [ ] Phone input: hint `'07700 000000'`, max 11 digits, only digits, starts 07
- [ ] Phone display: strip leading 0, prepend +44 → `'+44 ${num.substring(1)}'`
- [ ] Country flag: 🇬🇧 +44 (not 🇮🇳 +91)
- [ ] Addresses: London/UK format (street, city, postcode)
- [ ] Bank details: Sort Code + Account Number (UK standard)
- [ ] Vehicle brands: Honda, Yamaha, Ford, Vauxhall, VW, Mercedes-Benz (not Indian brands)

---

## WHAT USER APP SCREENS NEED (vs Driver App)

| Driver App Module | User App Equivalent |
|---|---|
| splash | splash (same GIF pattern) |
| onboarding | onboarding (3 screens, different copy) |
| auth/login | auth/login (same UK phone + OTP) |
| auth/register | auth/register (name, email, phone — no vehicle/docs) |
| dashboard (active orders) | home (browse, search, categories) |
| order_detail (accept/deliver) | order_tracking (track live delivery on map) |
| order_history | order_history (past orders, reorder) |
| earnings | wallet (balance, add money, withdraw) |
| notifications | notifications (same pattern) |
| profile (driver profile) | profile (user profile, saved addresses) |
| settings | settings (same pattern) |
| — | cart (items, quantities, checkout) |
| — | checkout (address, payment, place order) |
| — | restaurants/shops list |

---

## IMPORTANT PATTERNS TO PRESERVE

### Obx usage
```dart
// CORRECT — wraps Rx observable
Obx(() => Text(controller.someRxString.value))

// WRONG — wraps plain getter (causes GetX warning)
Obx(() => Text(controller.somePlainString))
// FIX: use Builder instead
Builder(builder: (_) => Text(controller.somePlainString))
```

### SingleChildScrollView for all input screens
```dart
body: SingleChildScrollView(
  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  child: Column(children: [...]),
),
```
Never use `Spacer()` inside a Column when keyboard can open. Use `SizedBox(height: N)`.

### SplashBinding
```dart
// MUST be Get.put, not Get.lazyPut
Get.put<SplashController>(SplashController());
```

### Repository fallback
```dart
} catch (_) {
  return ApiResponse<T>(success: true, message: '', data: AppData.field);
}
```

### Token strings
Access token: `'sd_access_token'`
Refresh token: `'sd_refresh_token'`

---

## EXPORT BARREL (`lib/export.dart`)
Single import in main.dart. Exports: flutter/material, get, get_storage, dio, shimmer, cached_network_image, all app/ and data/ files.
Any new file must be added to export.dart.

---

## DO NOT
- Do NOT use `setState` for business logic
- Do NOT import flutter/material.dart individually in feature files — use `export.dart`
- Do NOT use `print()` — use `AppLogger.d/i/w/e()`
- Do NOT add `DEMO_MODE` to .env or reference it in code
- Do NOT use class names `MockData`, `DemoData`, `FakeData`
- Do NOT use `message: 'demo'` in ApiResponse fallbacks
- Do NOT use ₹, +91, 🇮🇳 anywhere
- Do NOT add error handling for impossible scenarios (internal data is trusted)
- Do NOT add comments explaining what code does — only add WHY if non-obvious
- Do NOT create new `StatefulWidget`s when GetX controller state works
- Do NOT use `Get.lazyPut` for SplashController — it will never instantiate
- Do NOT wrap non-Rx values in `Obx` — use `Builder` instead

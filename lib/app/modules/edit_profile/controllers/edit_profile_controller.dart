import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:swiftdrop_customer_app/export.dart';

enum _ChangeTarget { none, phone, email }

class EditProfileController extends BaseController {
  final AuthRepository _repo;
  final ProfileRepository _profileRepo;
  EditProfileController(this._repo, this._profileRepo);

  // --- Current user mirror ---
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // --- Profile fields ---
  final nameController = TextEditingController();
  final displayPhoneController = TextEditingController();
  final newPhoneController = TextEditingController();
  final newEmailController = TextEditingController();

  final RxString countryCode = '+44'.obs;
  final RxString countryIso = 'GB'.obs;
  final RxString countryFlag = '🇬🇧'.obs;

  final RxString newPhoneNumber = ''.obs;
  final RxBool isNewPhoneValid = false.obs;
  final RxString newEmail = ''.obs;
  final RxBool isNewEmailValid = false.obs;
  final RxBool isNameDirty = false.obs;

  // Avatar picked locally — populated when the user picks a photo via the
  // camera/gallery sheet, cleared after a successful saveProfile.
  final RxnString selectedAvatarPath = RxnString();
  bool get isProfileDirty =>
      isNameDirty.value || selectedAvatarPath.value != null;

  // Granular per-action loaders so the Edit Profile "Save" button never
  // shows a spinner while a row's CHANGE suffix is the one fetching.
  final RxBool isStartingPhoneChange = false.obs;
  final RxBool isStartingEmailChange = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  String _initialName = '';
  String _lastNewPhoneText = '';
  String _lastNewEmailText = '';
  Worker? _userWorker;

  // --- OTP bucket: existing account (Screen C verify-existing + Screen G verify-account) ---
  final RxList<String> existingOtpValues =
      List.generate(AppConstants.otpLength, (_) => '').obs;
  final List<TextEditingController> existingOtpControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> existingOtpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final RxInt existingResendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResendExisting = false.obs;
  Timer? _existingResendCountdown;

  // --- OTP bucket: new phone (Screen D verify-new-phone) ---
  final RxList<String> newPhoneOtpValues =
      List.generate(AppConstants.otpLength, (_) => '').obs;
  final List<TextEditingController> newPhoneOtpControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> newPhoneOtpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final RxInt newPhoneResendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResendNewPhone = false.obs;
  Timer? _newPhoneResendCountdown;

  // --- OTP bucket: email (Screen F verify-email) ---
  final RxList<String> emailOtpValues =
      List.generate(AppConstants.otpLength, (_) => '').obs;
  final List<TextEditingController> emailOtpControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> emailOtpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final RxInt emailResendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResendEmail = false.obs;
  Timer? _emailResendCountdown;

  // Deletion shares the existing-account OTP bucket — it never runs
  // concurrently with the verify-existing flow, so a separate bucket would be
  // redundant. State unique to deletion: the masked target echoed by
  // /customer/profile/delete/initiate, the fetched reason list, the picked
  // reason, and the optional feedback text the user supplies on the
  // confirmation screen.
  final RxString deletionTarget = ''.obs;
  final RxList<DeletionReason> deletionReasons = <DeletionReason>[].obs;
  final Rx<DeletionReason?> selectedReason = Rx<DeletionReason?>(null);
  final deletionFeedbackController = TextEditingController();
  final RxBool isLoadingDeletionReasons = false.obs;

  static const List<DeletionReason> _fallbackReasons = [
    DeletionReason(id: 1, reason: "I don't want to use Swiftdrop anymore"),
    DeletionReason(id: 2, reason: "I'm using a different account"),
    DeletionReason(id: 3, reason: "I'm worried about my privacy"),
    DeletionReason(
        id: 4, reason: "You're sending me too many emails/notification"),
    DeletionReason(id: 5, reason: 'The app is not working properly'),
    DeletionReason(id: 6, reason: 'Other'),
  ];

  // --- Lifecycle ---

  @override
  void onInit() {
    super.onInit();
    _hydrateUser(AuthService.to.currentUser.value);
    _userWorker = ever<UserModel?>(AuthService.to.currentUser, _hydrateUser);
    nameController.addListener(_onNameChanged);
    newPhoneController.addListener(_onNewPhoneChanged);
    newEmailController.addListener(_onNewEmailChanged);
    deletionReasons.assignAll(_fallbackReasons);
    _refreshProfile();
    _loadDeletionReasons();
  }

  Future<void> _refreshProfile() async {
    final result = await _profileRepo.getProfile();
    if (result.success && result.data != null) {
      await AuthService.to.saveSession(
        accessToken: StorageService.to.read<String>(StorageKeys.authToken) ??
            AppConfig.accessTokenKey,
        user: result.data!,
      );
    }
  }

  void _hydrateUser(UserModel? user) {
    currentUser.value = user;
    final name = user?.name ?? '';
    _initialName = name;
    if (nameController.text != name) {
      nameController.text = name;
    }
    isNameDirty.value = false;
    final cc = user?.countryCode;
    if (cc != null && cc.isNotEmpty) countryCode.value = cc;
    final phone = user?.phone ?? '';
    final localPhone = phone.startsWith('0') ? phone.substring(1) : phone;
    if (displayPhoneController.text != localPhone) {
      displayPhoneController.text = localPhone;
    }
  }

  void _onNameChanged() {
    final current = nameController.text.trim();
    isNameDirty.value = current.isNotEmpty && current != _initialName.trim();
  }

  void _onNewPhoneChanged() {
    final text = newPhoneController.text;
    if (text == _lastNewPhoneText) return;
    _lastNewPhoneText = text;
    newPhoneNumber.value = text;
    isNewPhoneValid.value = AppUtils.isValidPhone(text);
  }

  void _onNewEmailChanged() {
    final text = newEmailController.text.trim();
    if (text == _lastNewEmailText) return;
    _lastNewEmailText = text;
    newEmail.value = text;
    isNewEmailValid.value = AppUtils.isValidEmail(text);
  }

  // --- Display helpers ---

  String _formatPhone(String? raw, String? code) {
    if (raw == null || raw.isEmpty) return '';
    final cc = (code != null && code.isNotEmpty) ? code : countryCode.value;
    final local = raw.startsWith('0') ? raw.substring(1) : raw;
    return '$cc-$local';
  }

  String get currentPhoneDisplay =>
      _formatPhone(currentUser.value?.phone, currentUser.value?.countryCode);

  String get newPhoneDisplay =>
      _formatPhone(newPhoneController.text, countryCode.value);

  String get currentEmailDisplay => currentUser.value?.email ?? '';

  String get newEmailDisplay => newEmailController.text.trim();

  // --- Country picker ---

  void selectCountry(String flag, String code, String iso) {
    countryFlag.value = flag;
    countryCode.value = code;
    countryIso.value = iso;
    newPhoneController.clear();
  }

  // --- Avatar picker ---

  Future<void> pickAvatarFromCamera() async {
    await _pickAvatar(ImageSource.camera);
  }

  Future<void> pickAvatarFromGallery() async {
    await _pickAvatar(ImageSource.gallery);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked != null) {
        selectedAvatarPath.value = picked.path;
      }
    } catch (e) {
      AppLogger.w('Image pick failed | $e');
      AppUtils.showError('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}.');
    }
  }

  // --- Save name + avatar ---

  Future<void> saveProfile() async {
    if (isLoading.value) return;
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppUtils.showError('Please enter your name.');
      return;
    }
    if (!isProfileDirty) {
      Get.back();
      return;
    }

    await runAsync(() async {
      final result = await _profileRepo.updateProfile(
        name: name,
        profilePhotoPath: selectedAvatarPath.value,
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      final updated = result.data ??
          currentUser.value?.copyWith(name: name);
      if (updated != null) {
        await AuthService.to.saveSession(
          accessToken: StorageService.to.read<String>(StorageKeys.authToken) ??
              AppConfig.accessTokenKey,
          user: updated,
        );
      }
      _initialName = name;
      isNameDirty.value = false;
      selectedAvatarPath.value = null;
      // Peel routes off the stack until we land on the Dashboard (Account tab
      // is preserved by DashboardController.currentIndex). This is more robust
      // than Get.back(), which only pops one route — if the user pushed
      // intermediate routes during the edit (e.g. visited Verify Existing),
      // Get.back() would land on the wrong screen.
      Get.until((route) => route.settings.name == AppRoutes.dashboard);
      AppUtils.showSuccess(
        result.message.isNotEmpty ? result.message : 'Profile updated.',
      );
    });
  }

  /// Backwards-compatible alias for older callers.
  Future<void> saveName() => saveProfile();

  // --- Delete account flow ---
  //
  // Tap path:
  //   Edit Profile Delete Account row → reason picker → confirmation
  //   → initiate API → Verify Account OTP → confirm-delete API → logout.

  /// Tap on "Delete Account" row in Edit Profile.
  /// Pure navigation — no API call here. Reasons were pre-fetched in onInit
  /// (with hardcoded fallback) so the picker opens instantly.
  void deleteAccount() {
    selectedReason.value = null;
    deletionFeedbackController.clear();
    Get.toNamed(AppRoutes.deleteAccountReason);
  }

  Future<void> _loadDeletionReasons() async {
    if (isLoadingDeletionReasons.value) return;
    isLoadingDeletionReasons.value = true;
    try {
      final result = await _profileRepo.getDeletionReasons();
      if (result.success && result.data != null && result.data!.isNotEmpty) {
        deletionReasons.assignAll(result.data!);
      }
    } finally {
      isLoadingDeletionReasons.value = false;
    }
  }

  /// Picks a reason on the Delete Account screen and routes to confirmation.
  void pickDeletionReason(DeletionReason reason) {
    selectedReason.value = reason;
    deletionFeedbackController.clear();
    Get.toNamed(AppRoutes.deleteAccountConfirmation);
  }

  /// Confirmation screen "Delete Account" tap. Hits initiate API and routes
  /// to the OTP screen.
  Future<void> confirmDeletionReason() async {
    if (isLoading.value) return;
    if (selectedReason.value == null) {
      AppUtils.showError('Please select a reason first.');
      return;
    }

    await runAsync(() async {
      final result = await _profileRepo.initiateProfileDeletion();
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: existingOtpValues,
        controllers: existingOtpControllers,
        timer: existingResendTimer,
        canResend: canResendExisting,
      );
      deletionTarget.value = (result.data?['target'] as String?) ?? '';
      Get.toNamed(AppRoutes.verifyAccountDeletion);
      _startCountdown(
        existingResendTimer,
        canResendExisting,
        _existingResendCountdown,
        (t) => _existingResendCountdown = t,
      );
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent. Use $testCode.');
      }
    });
  }

  void onDeletionOtpChanged(int index, String value) {
    existingOtpValues[index] = value;
  }

  Future<void> resendDeletionOtp() async {
    if (!canResendExisting.value || isLoading.value) return;
    await runAsync(() async {
      final result = await _profileRepo.initiateProfileDeletion();
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: existingOtpValues,
        controllers: existingOtpControllers,
        timer: existingResendTimer,
        canResend: canResendExisting,
      );
      _startCountdown(
        existingResendTimer,
        canResendExisting,
        _existingResendCountdown,
        (t) => _existingResendCountdown = t,
      );
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  /// Confirms the deletion OTP with reason_id + description + code, deletes
  /// the account, and logs out.
  Future<void> verifyDeletionOtp() async {
    if (isLoading.value) return;
    final code = existingOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }
    final reason = selectedReason.value;
    if (reason == null) {
      AppUtils.showError('Please select a reason first.');
      return;
    }

    await runAsync(() async {
      final result = await _profileRepo.confirmProfileDeletion(
        code: code,
        reasonId: reason.id,
        description: deletionFeedbackController.text.trim().isEmpty
            ? null
            : deletionFeedbackController.text.trim(),
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty
              ? result.message
              : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _existingResendCountdown?.cancel();
      _existingResendCountdown = null;
      await AuthService.to.logout();
      Get.offAllNamed(AppRoutes.login);
      AppUtils.showSuccess('Account deleted.');
    });
  }

  // --- OTP bucket reset helpers ---

  void _resetBucket({
    required RxList<String> values,
    required List<TextEditingController> controllers,
    required RxInt timer,
    required RxBool canResend,
  }) {
    values.fillRange(0, AppConstants.otpLength, '');
    for (final c in controllers) {
      c.clear();
    }
    timer.value = AppConstants.otpResendTimer;
    canResend.value = false;
  }

  Timer _startCountdown(RxInt timer, RxBool canResend, Timer? existing,
      void Function(Timer?) assign) {
    existing?.cancel();
    timer.value = AppConstants.otpResendTimer;
    canResend.value = false;
    final t = Timer.periodic(const Duration(seconds: 1), (tick) {
      if (timer.value > 0) {
        timer.value--;
      } else {
        canResend.value = true;
        tick.cancel();
        assign(null);
      }
    });
    assign(t);
    return t;
  }

  // ---- Phone / email change flow ----
  //
  // Order:
  //   Edit Profile  → Verify Existing Account → Change Phone/Email → Verify New
  //   (Change btn)    (OTP to current phone)    (enter new value)    (OTP to it)

  _ChangeTarget _pendingChange = _ChangeTarget.none;

  /// Edit-Profile "Change" tap on the phone row.
  Future<void> beginPhoneChange() async {
    if (isStartingPhoneChange.value) return;
    _pendingChange = _ChangeTarget.phone;
    newPhoneController.clear();
    isStartingPhoneChange.value = true;
    try {
      await _sendCurrentContactOtp();
    } finally {
      isStartingPhoneChange.value = false;
    }
  }

  /// Edit-Profile "Change" tap on the email row.
  /// If the user has no email on file yet, skip the verify-existing step and
  /// go straight to the Change Email screen.
  Future<void> beginEmailChange() async {
    if (isStartingEmailChange.value) return;
    _pendingChange = _ChangeTarget.email;
    newEmailController.clear();
    final existingEmail = currentUser.value?.email;
    if (existingEmail == null || existingEmail.isEmpty) {
      Get.toNamed(AppRoutes.changeEmail);
      return;
    }
    isStartingEmailChange.value = true;
    try {
      await _sendCurrentContactOtp();
    } finally {
      isStartingEmailChange.value = false;
    }
  }

  Future<void> _sendCurrentContactOtp() async {
    final user = currentUser.value;
    if (user == null) {
      AppUtils.showError('No user data available.');
      return;
    }

    final result = await _sendOtpForPendingChange(user);
    if (!result.success) {
      if (result.message.isNotEmpty) AppUtils.showError(result.message);
      return;
    }
    _resetBucket(
      values: existingOtpValues,
      controllers: existingOtpControllers,
      timer: existingResendTimer,
      canResend: canResendExisting,
    );
    Get.toNamed(AppRoutes.verifyExisting);
    _startCountdown(
      existingResendTimer,
      canResendExisting,
      _existingResendCountdown,
      (t) => _existingResendCountdown = t,
    );
    final testCode = result.data?['test_code'] as String?;
    if (testCode != null && testCode.isNotEmpty) {
      AppUtils.showSuccess('OTP sent. Use $testCode.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _sendOtpForPendingChange(
    UserModel user,
  ) {
    if (_pendingChange == _ChangeTarget.email) {
      return _repo.sendOtp(
        email: user.email,
        type: 'verify_current_email',
        channel: 'email',
      );
    }
    return _repo.sendOtp(
      mobile: user.phone,
      countryCode: user.countryCode ?? countryCode.value,
      countryIso: user.countryIso ?? countryIso.value,
      type: 'verify_current_phone',
      channel: 'phone',
    );
  }

  /// What the VerifyExisting screen shows under "OTP sent to …".
  String get verifyExistingTarget {
    switch (_pendingChange) {
      case _ChangeTarget.email:
        return currentUser.value?.email ?? '';
      case _ChangeTarget.phone:
      case _ChangeTarget.none:
        return currentPhoneDisplay;
    }
  }

  void onExistingOtpChanged(int index, String value) {
    existingOtpValues[index] = value;
  }

  Future<void> resendExistingOtp() async {
    if (!canResendExisting.value || isLoading.value) return;
    final user = currentUser.value;
    if (user == null) return;

    await runAsync(() async {
      final result = await _sendOtpForPendingChange(user);
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: existingOtpValues,
        controllers: existingOtpControllers,
        timer: existingResendTimer,
        canResend: canResendExisting,
      );
      _startCountdown(
        existingResendTimer,
        canResendExisting,
        _existingResendCountdown,
        (t) => _existingResendCountdown = t,
      );
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  /// Verifies the existing-account OTP. On success, routes the user to the
  /// appropriate Change screen based on which "Change" button started the flow.
  Future<void> verifyExistingOtp() async {
    if (isLoading.value) return;
    final code = existingOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }

    await runAsync(() async {
      final user = currentUser.value;
      final ApiResponse<Map<String, dynamic>> result;
      if (_pendingChange == _ChangeTarget.email) {
        result = await _repo.verifyOtp(
          email: user?.email,
          code: code,
          type: 'verify_current_email',
          channel: 'email',
        );
      } else {
        result = await _repo.verifyOtp(
          mobile: user?.phone,
          countryCode: user?.countryCode ?? countryCode.value,
          countryIso: user?.countryIso ?? countryIso.value,
          code: code,
          type: 'verify_current_phone',
          channel: 'phone',
        );
      }
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty
              ? result.message
              : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _existingResendCountdown?.cancel();
      _existingResendCountdown = null;

      switch (_pendingChange) {
        case _ChangeTarget.phone:
          Get.toNamed(AppRoutes.changePhone);
        case _ChangeTarget.email:
          Get.toNamed(AppRoutes.changeEmail);
        case _ChangeTarget.none:
          Get.back();
      }
    });
  }

  /// Change-Phone "Get OTP": sends OTP to the freshly typed new phone and
  /// routes to Verify New Phone.
  Future<void> sendNewPhoneOtp() async {
    if (isLoading.value) return;
    if (!isNewPhoneValid.value) {
      AppUtils.showError('Please enter a valid new mobile number.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.sendOtp(
        mobile: newPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'update_phone',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: newPhoneOtpValues,
        controllers: newPhoneOtpControllers,
        timer: newPhoneResendTimer,
        canResend: canResendNewPhone,
      );
      Get.toNamed(AppRoutes.verifyNewPhone);
      _startCountdown(
        newPhoneResendTimer,
        canResendNewPhone,
        _newPhoneResendCountdown,
        (t) => _newPhoneResendCountdown = t,
      );
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent. Use $testCode.');
      }
    });
  }

  void onNewPhoneOtpChanged(int index, String value) {
    newPhoneOtpValues[index] = value;
  }

  Future<void> resendNewPhoneOtp() async {
    if (!canResendNewPhone.value || isLoading.value) return;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        mobile: newPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'update_phone',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: newPhoneOtpValues,
        controllers: newPhoneOtpControllers,
        timer: newPhoneResendTimer,
        canResend: canResendNewPhone,
      );
      _startCountdown(
        newPhoneResendTimer,
        canResendNewPhone,
        _newPhoneResendCountdown,
        (t) => _newPhoneResendCountdown = t,
      );
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  /// Verifies the new phone OTP, updates the stored user, and pops back to
  /// the profile screen with a success snackbar.
  Future<void> verifyNewOtp() async {
    if (isLoading.value) return;
    final code = newPhoneOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.verifyOtp(
        mobile: newPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        code: code,
        type: 'update_phone',
        channel: 'phone',
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty
              ? result.message
              : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _newPhoneResendCountdown?.cancel();
      _newPhoneResendCountdown = null;

      final user = currentUser.value;
      if (user != null) {
        final updated = UserModel(
          id: user.id,
          name: user.name,
          phone: newPhoneController.text,
          email: user.email,
          avatar: user.avatar,
          countryCode: countryCode.value,
          type: user.type,
          vehicleType: user.vehicleType,
          vehicleNumber: user.vehicleNumber,
          rating: user.rating,
          totalDeliveries: user.totalDeliveries,
          isActive: user.isActive,
          isVerified: user.isVerified,
          isOnline: user.isOnline,
          walletBalance: user.walletBalance,
          createdAt: user.createdAt,
        );
        await AuthService.to.saveSession(
          accessToken: StorageService.to.read<String>(StorageKeys.authToken) ??
              AppConfig.accessTokenKey,
          user: updated,
        );
      }

      Get.until((route) => route.settings.name == AppRoutes.editProfile);
      AppUtils.showSuccess('Phone number updated.');
    });
  }

  // ---- Email change flow ----

  /// Sends OTP to the new email and navigates to Verify Email (Screen F).
  Future<void> sendEmailOtp() async {
    if (isLoading.value) return;
    if (!isNewEmailValid.value) {
      AppUtils.showError('Please enter a valid email address.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.sendOtp(
        email: newEmailController.text.trim(),
        type: 'update_email',
        channel: 'email',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: emailOtpValues,
        controllers: emailOtpControllers,
        timer: emailResendTimer,
        canResend: canResendEmail,
      );
      Get.toNamed(AppRoutes.verifyEmail);
      _startCountdown(
        emailResendTimer,
        canResendEmail,
        _emailResendCountdown,
        (t) => _emailResendCountdown = t,
      );
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent. Use $testCode.');
      }
    });
  }

  void onEmailOtpChanged(int index, String value) {
    emailOtpValues[index] = value;
  }

  Future<void> resendEmailOtp() async {
    if (!canResendEmail.value || isLoading.value) return;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        email: newEmailController.text.trim(),
        type: 'update_email',
        channel: 'email',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetBucket(
        values: emailOtpValues,
        controllers: emailOtpControllers,
        timer: emailResendTimer,
        canResend: canResendEmail,
      );
      _startCountdown(
        emailResendTimer,
        canResendEmail,
        _emailResendCountdown,
        (t) => _emailResendCountdown = t,
      );
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  /// Verifies the new email OTP, updates the stored user, and pops back to
  /// the profile screen with a success snackbar.
  Future<void> verifyEmailOtp() async {
    if (isLoading.value) return;
    final code = emailOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.verifyOtp(
        email: newEmailController.text.trim(),
        code: code,
        type: 'update_email',
        channel: 'email',
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty
              ? result.message
              : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _emailResendCountdown?.cancel();
      _emailResendCountdown = null;

      final user = currentUser.value;
      if (user != null) {
        final updated = user.copyWith(email: newEmailController.text.trim());
        await AuthService.to.saveSession(
          accessToken: StorageService.to.read<String>(StorageKeys.authToken) ??
              AppConfig.accessTokenKey,
          user: updated,
        );
      }

      Get.until((route) => route.settings.name == AppRoutes.editProfile);
      AppUtils.showSuccess('Email address updated.');
    });
  }

  // ---- Generic Verify Account (Screen G) — reuses existing-account bucket ----

  Future<void> submitAccountVerification() async {
    if (isLoading.value) return;
    final code = existingOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }
    await runAsync(() async {
      final result = await _repo.verifyOtp(
        mobile: currentUser.value?.phone,
        countryCode: currentUser.value?.countryCode ?? countryCode.value,
        countryIso: currentUser.value?.countryIso ?? countryIso.value,
        code: code,
        type: 'verify_current_phone',
        channel: 'phone',
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty
              ? result.message
              : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _existingResendCountdown?.cancel();
      _existingResendCountdown = null;
      Get.back();
      AppUtils.showSuccess('Account verified.');
    });
  }

  // ---- Lifecycle teardown ----

  @override
  void onClose() {
    _userWorker?.dispose();
    _userWorker = null;
    _existingResendCountdown?.cancel();
    _newPhoneResendCountdown?.cancel();
    _emailResendCountdown?.cancel();
    nameController.removeListener(_onNameChanged);
    newPhoneController.removeListener(_onNewPhoneChanged);
    newEmailController.removeListener(_onNewEmailChanged);
    nameController.dispose();
    displayPhoneController.dispose();
    newPhoneController.dispose();
    newEmailController.dispose();
    deletionFeedbackController.dispose();
    for (final c in existingOtpControllers) {
      c.dispose();
    }
    for (final f in existingOtpFocusNodes) {
      f.dispose();
    }
    for (final c in newPhoneOtpControllers) {
      c.dispose();
    }
    for (final f in newPhoneOtpFocusNodes) {
      f.dispose();
    }
    for (final c in emailOtpControllers) {
      c.dispose();
    }
    for (final f in emailOtpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}

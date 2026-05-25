import 'dart:async';

import 'package:swiftdrop_customer_app/export.dart';

class AuthController extends BaseController {
  final AuthRepository _repo;
  AuthController(this._repo);

  // --- Login fields ---
  final phoneController = TextEditingController();
  final RxString phoneNumber = ''.obs;
  final RxBool isPhoneValid = false.obs;
  final RxString countryCode = '+44'.obs;
  final RxString countryIso = 'GB'.obs;
  final RxString countryFlag = '🇬🇧'.obs;

  // --- Register fields ---
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final regPhoneController = TextEditingController();
  final RxString regPhoneNumber = ''.obs;
  final RxBool regIsPhoneValid = false.obs;

  // --- Login OTP state ---
  final RxList<String> otpValues = List.generate(AppConstants.otpLength, (_) => '').obs;
  final RxInt resendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResend = false.obs;
  Timer? _resendCountdown;

  final List<FocusNode> otpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final List<TextEditingController> otpBoxControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());

  // --- Register OTP state ---
  final RxBool isEmailValid = false.obs;
  final RxBool isEmailVerified = false.obs;
  final RxBool isPhoneVerified = false.obs;
  final RxBool emailOtpSent = false.obs;
  final RxBool regPhoneOtpSent = false.obs;

  // --- Granular loading flags (one per inline action) ---
  final RxBool isSendingEmailOtp = false.obs;
  final RxBool isVerifyingEmailOtp = false.obs;
  final RxBool isSendingPhoneOtp = false.obs;
  final RxBool isVerifyingPhoneOtp = false.obs;

  final RxList<String> emailOtpValues =
      List.generate(AppConstants.otpLength, (_) => '').obs;
  final RxList<String> regPhoneOtpValues =
      List.generate(AppConstants.otpLength, (_) => '').obs;

  final RxInt emailResendTimer = AppConstants.otpResendTimer.obs;
  final RxInt regPhoneResendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResendEmail = false.obs;
  final RxBool canResendRegPhone = false.obs;

  Timer? _emailResendCountdown;
  Timer? _regPhoneResendCountdown;

  final List<FocusNode> emailOtpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final List<TextEditingController> emailOtpBoxControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> regPhoneOtpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final List<TextEditingController> regPhoneOtpBoxControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());

  String _lastPhoneText = '';
  String _lastEmailText = '';
  String _lastRegPhoneText = '';

  // --- Computed ---
  String get displayPhone {
    final local = phoneNumber.value.startsWith('0')
        ? phoneNumber.value.substring(1)
        : phoneNumber.value;
    return '${countryCode.value}-$local';
  }

  void selectCountry(String flag, String code, String iso) {
    countryFlag.value = flag;
    countryCode.value = code;
    countryIso.value = iso;

    phoneController.clear();

    regPhoneController.clear();
    regPhoneNumber.value = '';
    regIsPhoneValid.value = false;
    isPhoneVerified.value = false;
    regPhoneOtpSent.value = false;
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) {
      c.clear();
    }
    _regPhoneResendCountdown?.cancel();
    _regPhoneResendCountdown = null;
    regPhoneResendTimer.value = AppConstants.otpResendTimer;
    canResendRegPhone.value = false;
  }

  String get _fullOtp => otpValues.join();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_onPhoneControllerChanged);
    emailController.addListener(_onEmailControllerChanged);
    regPhoneController.addListener(_onRegPhoneControllerChanged);
  }

  void _onPhoneControllerChanged() {
    final text = phoneController.text;
    if (text == _lastPhoneText) return;
    _lastPhoneText = text;
    phoneNumber.value = text;
    isPhoneValid.value = AppUtils.isValidPhone(text);
  }

  void _onEmailControllerChanged() {
    final text = emailController.text.trim();
    if (text == _lastEmailText) return;
    _lastEmailText = text;
    isEmailValid.value = AppUtils.isValidEmail(text);
    isEmailVerified.value = false;
    emailOtpSent.value = false;
  }

  void _onRegPhoneControllerChanged() {
    final text = regPhoneController.text;
    if (text == _lastRegPhoneText) return;
    _lastRegPhoneText = text;
    regPhoneNumber.value = text;
    regIsPhoneValid.value = AppUtils.isValidPhone(text);
    isPhoneVerified.value = false;
    regPhoneOtpSent.value = false;
  }

  void cancelTimer() {
    _resendCountdown?.cancel();
    _resendCountdown = null;
  }

  void _resetOtpState() {
    otpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in otpBoxControllers) {
      c.clear();
    }
    resendTimer.value = AppConstants.otpResendTimer;
    canResend.value = false;
  }

  // ---- Login OTP flow ----

  Future<void> sendOtp() async {
    if (isLoading.value) return;
    if (!isPhoneValid.value) {
      AppUtils.showError('Please enter a valid mobile number.');
      return;
    }
    https://i.diawi.com/Mi9Jsd
    await runAsync(() async {
      final result = await _repo.sendOtp(
        mobile: phoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'login',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _resetOtpState();
      Get.toNamed(AppRoutes.otp);
      _startResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      }
    });
  }

  void _startResendTimer() {
    _resendCountdown?.cancel();
    resendTimer.value = AppConstants.otpResendTimer;
    canResend.value = false;

    _resendCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
        _resendCountdown = null;
      }
    });
  }

  void onOtpDigitChanged(int index, String value) {
    otpValues[index] = value;
  }

  Future<void> verifyOtp() async {
    if (isLoading.value) return;
    if (_fullOtp.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.verifyOtp(
        mobile: phoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        code: _fullOtp,
        type: 'login',
        channel: 'phone',
      );

      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }

      if (result.data != null) {
        final data = result.data!;
        final token = data['token'] as String?;
        if (token != null) {
          final userJson = data['user'] as Map<String, dynamic>?;
          final user = userJson != null
              ? UserModel.fromJson(userJson)
              : AuthService.to.currentUser.value ?? AppData.user;
          await AuthService.to.saveSession(accessToken: token, user: user);
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.register);
        }
      }
    });
  }

  Future<void> resendOtp() async {
    if (!canResend.value || isLoading.value) return;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        mobile: phoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'login',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      otpValues.fillRange(0, AppConstants.otpLength, '');
      for (final c in otpBoxControllers) {
        c.clear();
      }
      _startResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      } else {
        AppUtils.showSuccess('OTP resent successfully.');
      }
    });
  }

  // ---- Register email OTP flow ----

  Future<void> sendEmailOtp() async {
    if (isSendingEmailOtp.value || !isEmailValid.value) return;
    isSendingEmailOtp.value = true;
    try {
      final result = await _repo.sendOtp(
        email: emailController.text.trim(),
        type: 'signup',
        channel: 'email',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      emailOtpValues.fillRange(0, AppConstants.otpLength, '');
      for (final c in emailOtpBoxControllers) {
        c.clear();
      }
      emailOtpSent.value = true;
      _startEmailResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      }
    } finally {
      isSendingEmailOtp.value = false;
    }
  }

  void onEmailOtpDigitChanged(int index, String value) {
    emailOtpValues[index] = value;
  }

  Future<void> verifyEmailOtp() async {
    final code = emailOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete verification code.');
      return;
    }
    if (isVerifyingEmailOtp.value) return;
    isVerifyingEmailOtp.value = true;
    try {
      final result = await _repo.verifyOtp(
        email: emailController.text.trim(),
        code: code,
        type: 'signup',
        channel: 'email',
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty ? result.message : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _emailResendCountdown?.cancel();
      _emailResendCountdown = null;
      isEmailVerified.value = true;
      emailOtpSent.value = false;
    } finally {
      isVerifyingEmailOtp.value = false;
    }
  }

  Future<void> resendEmailOtp() async {
    if (!canResendEmail.value) return;
    emailOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in emailOtpBoxControllers) {
      c.clear();
    }
    isSendingEmailOtp.value = true;
    try {
      final result = await _repo.sendOtp(
        email: emailController.text.trim(),
        type: 'signup',
        channel: 'email',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _startEmailResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      } else {
        AppUtils.showSuccess('Verification code resent.');
      }
    } finally {
      isSendingEmailOtp.value = false;
    }
  }

  void _startEmailResendTimer() {
    _emailResendCountdown?.cancel();
    emailResendTimer.value = AppConstants.otpResendTimer;
    canResendEmail.value = false;
    _emailResendCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (emailResendTimer.value > 0) {
        emailResendTimer.value--;
      } else {
        canResendEmail.value = true;
        timer.cancel();
        _emailResendCountdown = null;
      }
    });
  }

  // ---- Register phone OTP flow ----

  Future<void> sendRegisterPhoneOtp() async {
    if (isSendingPhoneOtp.value || !regIsPhoneValid.value) return;
    isSendingPhoneOtp.value = true;
    try {
      final result = await _repo.sendOtp(
        mobile: regPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'signup',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
      for (final c in regPhoneOtpBoxControllers) {
        c.clear();
      }
      regPhoneOtpSent.value = true;
      _startRegPhoneResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      }
    } finally {
      isSendingPhoneOtp.value = false;
    }
  }

  void onRegPhoneOtpDigitChanged(int index, String value) {
    regPhoneOtpValues[index] = value;
  }

  Future<void> verifyRegisterPhoneOtp() async {
    final code = regPhoneOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete verification code.');
      return;
    }
    if (isVerifyingPhoneOtp.value) return;
    isVerifyingPhoneOtp.value = true;
    try {
      final result = await _repo.verifyOtp(
        mobile: regPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        code: code,
        type: 'signup',
        channel: 'phone',
      );
      if (!result.success) {
        AppUtils.showError(
          result.message.isNotEmpty ? result.message : 'Invalid OTP. Please enter the correct code.',
        );
        return;
      }
      _regPhoneResendCountdown?.cancel();
      _regPhoneResendCountdown = null;
      isPhoneVerified.value = true;
      regPhoneOtpSent.value = false;
    } finally {
      isVerifyingPhoneOtp.value = false;
    }
  }

  Future<void> resendRegisterPhoneOtp() async {
    if (!canResendRegPhone.value) return;
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) {
      c.clear();
    }
    isSendingPhoneOtp.value = true;
    try {
      final result = await _repo.sendOtp(
        mobile: regPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        type: 'signup',
        channel: 'phone',
      );
      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }
      _startRegPhoneResendTimer();
      final testCode = result.data?['test_code'] as String?;
      if (testCode != null && testCode.isNotEmpty) {
        AppUtils.showSuccess('OTP sent successfully. Please enter $testCode as OTP.');
      } else {
        AppUtils.showSuccess('OTP resent successfully.');
      }
    } finally {
      isSendingPhoneOtp.value = false;
    }
  }

  void _startRegPhoneResendTimer() {
    _regPhoneResendCountdown?.cancel();
    regPhoneResendTimer.value = AppConstants.otpResendTimer;
    canResendRegPhone.value = false;
    _regPhoneResendCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (regPhoneResendTimer.value > 0) {
        regPhoneResendTimer.value--;
      } else {
        canResendRegPhone.value = true;
        timer.cancel();
        _regPhoneResendCountdown = null;
      }
    });
  }

  // ---- Register state reset ----

  void resetRegisterState() {
    nameController.clear();
    emailController.clear();
    regPhoneController.clear();
    _lastEmailText = '';
    _lastRegPhoneText = '';
    isEmailValid.value = false;
    isEmailVerified.value = false;
    isPhoneVerified.value = false;
    emailOtpSent.value = false;
    regPhoneOtpSent.value = false;
    emailOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in emailOtpBoxControllers) {
      c.clear();
    }
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) {
      c.clear();
    }
    _emailResendCountdown?.cancel();
    _emailResendCountdown = null;
    _regPhoneResendCountdown?.cancel();
    _regPhoneResendCountdown = null;
    emailResendTimer.value = AppConstants.otpResendTimer;
    regPhoneResendTimer.value = AppConstants.otpResendTimer;
    canResendEmail.value = false;
    canResendRegPhone.value = false;
  }

  // ---- Submit register ----

  Future<void> submitRegister() async {
    if (isLoading.value) return;
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppUtils.showError('Please enter your full name.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.register(
        name: name,
        mobile: regPhoneController.text,
        countryCode: countryCode.value,
        countryIso: countryIso.value,
        email: emailController.text.trim(),
      );

      if (!result.success) {
        if (result.message.isNotEmpty) AppUtils.showError(result.message);
        return;
      }

      final data = result.data;
      final token = data?['token'] as String? ?? AppConfig.accessTokenKey;
      final userJson = data?['user'] as Map<String, dynamic>?;
      final user = userJson != null
          ? UserModel.fromJson(userJson)
          : AppData.user.copyWith(name: name, email: emailController.text.trim());

      await AuthService.to.saveSession(accessToken: token, user: user);
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }

  @override
  void onClose() {
    _resendCountdown?.cancel();
    _emailResendCountdown?.cancel();
    _regPhoneResendCountdown?.cancel();
    phoneController.removeListener(_onPhoneControllerChanged);
    emailController.removeListener(_onEmailControllerChanged);
    regPhoneController.removeListener(_onRegPhoneControllerChanged);
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    regPhoneController.dispose();
    for (final node in otpFocusNodes) {
      node.dispose();
    }
    for (final c in otpBoxControllers) {
      c.dispose();
    }
    for (final node in emailOtpFocusNodes) {
      node.dispose();
    }
    for (final c in emailOtpBoxControllers) {
      c.dispose();
    }
    for (final node in regPhoneOtpFocusNodes) {
      node.dispose();
    }
    for (final c in regPhoneOtpBoxControllers) {
      c.dispose();
    }
    super.onClose();
  }
}

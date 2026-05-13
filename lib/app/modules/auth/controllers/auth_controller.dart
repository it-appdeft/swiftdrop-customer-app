import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';

class AuthController extends BaseController {
  final AuthRepository _repo;
  AuthController(this._repo);

  // --- Login fields ---
  final phoneController = TextEditingController();
  final RxString phoneNumber = ''.obs;
  final RxBool isPhoneValid = false.obs;
  final RxString countryCode = '+44'.obs;
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

  void selectCountry(String flag, String code) {
    countryFlag.value = flag;
    countryCode.value = code;
    phoneController.clear();
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

    await runAsync(() async {
      await _repo.sendOtp(phoneController.text);
      _resetOtpState();
      Get.toNamed(AppRoutes.otp);
      _startResendTimer();
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
        phone: phoneController.text,
        otp: _fullOtp,
      );

      if (result.success && result.data != null) {
        final data = result.data!;
        final user = data['user'] != null
            ? (data['user'] as Map<String, dynamic>)
            : null;

        if (user != null) {
          await AuthService.to.saveSession(
            accessToken: data['accessToken'] as String? ?? 'sd_access_token',
            refreshToken: data['refreshToken'] as String? ?? 'sd_refresh_token',
            user: AuthService.to.currentUser.value ?? UserModel.fromJson(user),
          );
        }
        Get.offAllNamed(AppRoutes.dashboard);
      }
    });
  }

  Future<void> resendOtp() async {
    if (!canResend.value || isLoading.value) return;
    await runAsync(() async {
      await _repo.sendOtp(phoneController.text);
      otpValues.fillRange(0, AppConstants.otpLength, '');
      for (final c in otpBoxControllers) {
        c.clear();
      }
      _startResendTimer();
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  // ---- Register email OTP flow ----

  void sendEmailOtp() {
    if (!isEmailValid.value) {
      AppUtils.showError('Please enter a valid email address.');
      return;
    }
    emailOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in emailOtpBoxControllers) {
      c.clear();
    }
    emailOtpSent.value = true;
    _startEmailResendTimer();
  }

  void onEmailOtpDigitChanged(int index, String value) {
    emailOtpValues[index] = value;
  }

  void verifyEmailOtp() {
    final code = emailOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete verification code.');
      return;
    }
    _emailResendCountdown?.cancel();
    _emailResendCountdown = null;
    isEmailVerified.value = true;
    emailOtpSent.value = false;
  }

  void resendEmailOtp() {
    if (!canResendEmail.value) return;
    emailOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in emailOtpBoxControllers) {
      c.clear();
    }
    _startEmailResendTimer();
    AppUtils.showSuccess('Verification code resent.');
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

  void sendRegisterPhoneOtp() {
    if (!regIsPhoneValid.value) {
      AppUtils.showError('Please enter a valid mobile number.');
      return;
    }
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) {
      c.clear();
    }
    regPhoneOtpSent.value = true;
    _startRegPhoneResendTimer();
  }

  void onRegPhoneOtpDigitChanged(int index, String value) {
    regPhoneOtpValues[index] = value;
  }

  void verifyRegisterPhoneOtp() {
    final code = regPhoneOtpValues.join();
    if (code.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete verification code.');
      return;
    }
    _regPhoneResendCountdown?.cancel();
    _regPhoneResendCountdown = null;
    isPhoneVerified.value = true;
    regPhoneOtpSent.value = false;
  }

  void resendRegisterPhoneOtp() {
    if (!canResendRegPhone.value) return;
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) {
      c.clear();
    }
    _startRegPhoneResendTimer();
    AppUtils.showSuccess('OTP resent successfully.');
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
    for (final c in emailOtpBoxControllers) c.clear();
    regPhoneOtpValues.fillRange(0, AppConstants.otpLength, '');
    for (final c in regPhoneOtpBoxControllers) c.clear();
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
        phone: regPhoneController.text,
        email: emailController.text.trim(),
      );

      if (result.success && result.data != null) {
        await AuthService.to.saveSession(
          accessToken: 'sd_access_token',
          refreshToken: 'sd_refresh_token',
          user: result.data!,
        );
        Get.offAllNamed(AppRoutes.dashboard);
      }
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

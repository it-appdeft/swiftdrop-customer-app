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

  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final RxString phoneNumber = ''.obs;
  final RxBool isPhoneValid = false.obs;
  final RxList<String> otpValues = List.generate(AppConstants.otpLength, (_) => '').obs;
  final RxInt resendTimer = AppConstants.otpResendTimer.obs;
  final RxBool canResend = false.obs;

  final RxString countryCode = '+44'.obs;
  final RxString countryFlag = '🇬🇧'.obs;

  Timer? _resendCountdown;

  final List<FocusNode> otpFocusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final List<TextEditingController> otpBoxControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());

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
  }

  void _onPhoneControllerChanged() {
    phoneNumber.value = phoneController.text;
    isPhoneValid.value = AppUtils.isValidPhone(phoneController.text);
  }

  Future<void> sendOtp() async {
    if (!isPhoneValid.value) {
      AppUtils.showError('Please enter a valid mobile number.');
      return;
    }

    await runAsync(() async {
      await _repo.sendOtp(phoneController.text);
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
    if (_fullOtp.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP.');
      return;
    }

    if (_fullOtp != AppConstants.defaultOtp) {
      AppUtils.showError('Invalid OTP. Please enter the correct code.');
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
    if (!canResend.value) return;
    await runAsync(() async {
      await _repo.sendOtp(phoneController.text);
      otpValues.fillRange(0, AppConstants.otpLength, '');
      for (final c in otpBoxControllers) c.clear();
      _startResendTimer();
      AppUtils.showSuccess('OTP resent successfully.');
    });
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppUtils.showError('Please enter your full name.');
      return;
    }
    if (!isPhoneValid.value) {
      AppUtils.showError('Please enter a valid mobile number.');
      return;
    }

    await runAsync(() async {
      final result = await _repo.register(
        name: name,
        phone: phoneController.text,
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      );

      if (result.success && result.data != null) {
        Get.toNamed(AppRoutes.otp);
        _startResendTimer();
      }
    });
  }

  @override
  void onClose() {
    _resendCountdown?.cancel();
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    for (final node in otpFocusNodes) node.dispose();
    for (final c in otpBoxControllers) c.dispose();
    super.onClose();
  }
}

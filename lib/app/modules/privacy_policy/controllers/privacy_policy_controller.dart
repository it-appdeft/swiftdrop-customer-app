import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';

class PrivacyPolicyController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final paragraphs = <String>[].obs;
  final isLoading = true.obs;

  final String fallbackText =
      'This Privacy Policy describes how SwiftDrop collects, uses, and shares your personal information when you use our website or mobile application.';

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    isLoading.value = true;
    try {
      final res = await _repo.getPrivacyPolicy();
      if (res.success && res.data != null) {
        final data = res.data!;
        final pList = (data['data']?['paragraphs'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (pList.isNotEmpty) {
          paragraphs.value = pList;
        } else {
          final html = data['data']?['html'] as String? ?? '';
          if (html.isNotEmpty) {
            paragraphs.value = [html.replaceAll(RegExp(r'<[^>]*>'), '')];
          }
        }
      }
    } catch (_) {}
    if (paragraphs.isEmpty) {
      paragraphs.value = [fallbackText];
    }
    isLoading.value = false;
  }
}

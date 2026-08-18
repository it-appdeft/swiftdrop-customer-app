import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';

class TermsConditionsController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final paragraphs = <String>[].obs;
  final isLoading = true.obs;

  final String fallbackText =
      'By using SwiftDrop, you agree to be bound by these Terms & Conditions. Please read them carefully before placing an order.';

  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    isLoading.value = true;
    try {
      final res = await _repo.getTermsAndConditions();
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

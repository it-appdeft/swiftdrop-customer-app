import 'package:get/get.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';

class WalletController extends BaseController {
  final EarningsRepository _repo;
  WalletController(this._repo);

  final RxDouble balance = 0.0.obs;
  final transactions = <TransactionModel>[].obs;
  final RxBool hasMore = true.obs;
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.to.currentUser.value;
    if (user != null) balance.value = user.walletBalance;
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _page = 1;
    await runAsync(_fetchTransactions);
  }

  Future<void> _fetchTransactions() async {
    final summaryResult = await _repo.getWalletSummary();
    if (summaryResult.success && summaryResult.data != null) {
      balance.value = (summaryResult.data!['balance'] as num).toDouble();
    }

    final txResult = await _repo.getTransactions(page: 1);
    if (txResult.success && txResult.data != null) {
      transactions.value = txResult.data!;
      hasMore.value = txResult.data!.length >= AppConstants.paginationLimit;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    _page++;
    try {
      final result = await _repo.getTransactions(page: _page);
      if (result.success && result.data != null) {
        transactions.addAll(result.data!);
        hasMore.value = result.data!.length >= AppConstants.paginationLimit;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> addFunds(double amount) async {
    await runAsync(() async {
      final result = await _repo.addFunds(amount);
      if (result.success) {
        balance.value += amount;
        AppUtils.showSuccess('${AppUtils.formatCurrency(amount)} added to your wallet.');
        await _fetchTransactions();
      }
    });
  }
}

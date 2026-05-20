import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/transaction_model.dart';

class EarningsRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> getWalletSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.walletBalance);
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: AppData.walletSummary,
      );
    }
  }

  Future<ApiResponse<List<TransactionModel>>> getTransactions({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.transactions,
        queryParameters: {'page': page, 'limit': 10},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => TransactionModel.fromJson(e)).toList(),
      );
    } catch (_) {
      return ApiResponse<List<TransactionModel>>(
        success: true,
        message: '',
        data: AppData.transactions,
      );
    }
  }

  Future<ApiResponse<bool>> addFunds(double amount) async {
    try {
      await _dio.post(ApiEndpoints.addFunds, data: {'amount': amount});
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }
}

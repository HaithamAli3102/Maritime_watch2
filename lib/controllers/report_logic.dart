
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../services/api_client.dart';

class ReportLogic extends GetxController {
  final ApiClient apiClient = ApiClient();

  // Observable variables for state management
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReportModel?> reportResponse = Rx<ReportModel?>(null);
  final RxList<ReportModel> reports = <ReportModel>[].obs;
  final RxMap<String, String> validationErrors = <String, String>{}.obs;

  // ==================== GET ALL REPORTS ====================

  Future<List<ReportModel>> getReports() async {
    try {
      // Set loading state
      isLoading.value = true;
      isSuccess.value = false;
      errorMessage.value = '';

      final response = await apiClient.dio.get(
        '/reports',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats

        // If response is a list
        if (response.data is List) {
          final List<dynamic> data = response.data;
          final List<ReportModel> reportList = data
              .map((json) => ReportModel.fromJson(json))
              .toList();

          reports.value = reportList;
          isSuccess.value = true;

          print('✅ Reports fetched successfully: ${reports.length} reports');

          return reportList;
        }
        // If response is a single object
        else if (response.data is Map) {
          final report = ReportModel.fromJson(response.data);
          reportResponse.value = report;
          reports.value = [report];
          isSuccess.value = true;

          print('✅ Report fetched successfully: ${report.reportId}');

          return [report];
        }
        // If response is empty or unexpected format
        else {
          reports.clear();
          isSuccess.value = true;
          print('ℹ️ No reports found or unexpected format');
          return [];
        }
      } else {
        // Handle non-200 responses
        String errorMsg = 'Failed to fetch reports: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          errorMsg = response.data['message'] ?? errorMsg;
        }

        errorMessage.value = errorMsg;
        isSuccess.value = false;

        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 4),
        );

        return [];
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      String errorMsg = 'Network error occurred';

      if (e.response != null) {
        final responseData = e.response?.data;
        print('❌ Dio error response: $responseData');

        if (responseData != null && responseData is Map) {
          errorMsg = responseData['message'] ?? 'Server error: ${e.response?.statusCode}';
        } else {
          errorMsg = 'Server error: ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'No internet connection. Please check your network.';
      }

      errorMessage.value = errorMsg;
      isSuccess.value = false;

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );

      print('❌ Error fetching reports: $errorMsg');
      return [];
    } catch (e) {
      // Handle any other errors
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      isSuccess.value = false;

      Get.snackbar(
        'Error',
        'Failed to load reports',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );

      print('❌ Unexpected error: $e');
      return [];
    } finally {
      // Always reset loading state
      isLoading.value = false;
    }
  }

  // ==================== GET SINGLE REPORT BY ID ====================

  Future<ReportModel?> getReportById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiClient.dio.get(
        '/reports/$id',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final report = ReportModel.fromJson(response.data);
        reportResponse.value = report;
        isSuccess.value = true;

        print('✅ Report fetched successfully: ${report.reportId}');
        return report;
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Report not found';
        isSuccess.value = false;
        return null;
      } else {
        String errorMsg = 'Failed to fetch report: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          errorMsg = response.data['message'] ?? errorMsg;
        }
        errorMessage.value = errorMsg;
        isSuccess.value = false;
        return null;
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error occurred';

      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          errorMsg = 'Report not found';
        } else {
          errorMsg = e.response?.data['message'] ?? 'Server error: ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'No internet connection. Please check your network.';
      }

      errorMessage.value = errorMsg;
      isSuccess.value = false;
      return null;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      isSuccess.value = false;
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GET REPORTS BY ZONE ID ====================

  Future<List<ReportModel>> getReportsByZone(String zoneId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiClient.dio.get(
        '/reports/zone/$zoneId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          final List<ReportModel> reportList = data
              .map((json) => ReportModel.fromJson(json))
              .toList();

          reports.value = reportList;
          isSuccess.value = true;
          return reportList;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reports by zone: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GET REPORTS BY DATE RANGE ====================

  Future<List<ReportModel>> getReportsByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiClient.dio.get(
        '/reports',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          final List<ReportModel> reportList = data
              .map((json) => ReportModel.fromJson(json))
              .toList();

          reports.value = reportList;
          isSuccess.value = true;
          return reportList;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reports by date range: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE REPORT ====================

  Future<bool> deleteReport(int reportId) async {
    try {
      isLoading.value = true;

      final response = await apiClient.dio.delete(
        '/reports/$reportId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from list
        reports.removeWhere((report) => report.reportId == reportId);
        isSuccess.value = true;

        Get.snackbar(
          'Success',
          'Report deleted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );

        return true;
      } else {
        String errorMsg = 'Failed to delete report: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          errorMsg = response.data['message'] ?? errorMsg;
        }
        errorMessage.value = errorMsg;
        isSuccess.value = false;
        return false;
      }
    } catch (e) {
      print('Error deleting report: $e');
      errorMessage.value = 'Failed to delete report';
      isSuccess.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPDATE REPORT ====================

  Future<ReportModel?> updateReport(int reportId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      final response = await apiClient.dio.put(
        '/reports/$reportId',
        data: data,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final report = ReportModel.fromJson(response.data);

        // Update in list
        final index = reports.indexWhere((r) => r.reportId == reportId);
        if (index != -1) {
          reports[index] = report;
        }

        reportResponse.value = report;
        isSuccess.value = true;

        Get.snackbar(
          'Success',
          'Report updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );

        return report;
      } else {
        String errorMsg = 'Failed to update report: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          errorMsg = response.data['message'] ?? errorMsg;
        }
        errorMessage.value = errorMsg;
        isSuccess.value = false;
        return null;
      }
    } catch (e) {
      print('Error updating report: $e');
      errorMessage.value = 'Failed to update report';
      isSuccess.value = false;
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  // Reset states
  void resetState() {
    isLoading.value = false;
    isSuccess.value = false;
    errorMessage.value = '';
    reportResponse.value = null;
    validationErrors.clear();
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
    validationErrors.clear();
  }

  // Getters
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isReportAdded => isSuccess.value;
  bool get hasReports => reports.isNotEmpty;
  int get reportsCount => reports.length;

  // Get validation errors
  Map<String, String> getErrors() => validationErrors;

// ==================== ADD REPORT ====================

// ... (your existing addReport method here)
}
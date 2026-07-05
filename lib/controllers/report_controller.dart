// controllers/report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/zone_model.dart';
import '../services/api_client.dart';
import '../models/report_model.dart';

class ReportController extends GetxController {
  final ApiClient apiClient = ApiClient();

  // Observable variables for state management
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReportModel?> reportResponse = Rx<ReportModel?>(null);
  final RxMap<String, String> validationErrors = <String, String>{}.obs;

  // Method to add a new report
  Future<ReportModel?> addReport({
    required String date,
    required String latitude,
    required String longitude,
    required String address,
    required String zoneId,
    required String color,
    required int numberOfPeople,
    required String description,
    required String photo,
    required String name,
    required String phone,
    required int urgencyId,
  }) async {
    try {
      // Set loading state
      isLoading.value = true;
      isSuccess.value = false;
      errorMessage.value = '';
      validationErrors.clear();

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'date': date,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'zone_id': zoneId,
        'color': color,
        'number_of_people': numberOfPeople,
        'description': description,
        'photo': photo,
        'name': name,
        'phone': phone,
        'urgency_id': urgencyId,
      };

      print('📤 Sending report: $requestBody');

      // Make the API call
      final response = await apiClient.dio.post(
        '/reports',
        data: requestBody,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final report = ReportModel.fromJson(response.data);
        reportResponse.value = report;
        isSuccess.value = true;

        Get.snackbar(
          'Success',
          'Report added successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return report;
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errorData = response.data as Map<String, dynamic>;
        String errorMsg = 'Validation failed. Please check your input.';

        print('⚠️ Validation errors: $errorData');

        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          validationErrors.clear();

          final List<String> errorMessages = [];
          errors.forEach((field, messages) {
            String fieldName = _formatFieldName(field);
            if (messages is List) {
              final fieldError = messages.join(', ');
              validationErrors[field] = fieldError;
              errorMessages.add('• $fieldName: $fieldError');
            } else if (messages is String) {
              validationErrors[field] = messages;
              errorMessages.add('• $fieldName: $messages');
            }
          });

          errorMsg = errorMessages.join('\n');
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'];
        }

        errorMessage.value = errorMsg;
        isSuccess.value = false;

        Get.snackbar(
          'Validation Error',
          'Please check the form for errors',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              _showValidationDialog();
            },
            child: const Text(
              'VIEW DETAILS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        print('❌ Validation Errors:');
        validationErrors.forEach((field, message) {
          print('   $field: $message');
        });

        return Future.error(errorMsg);
      } else {
        String errorMsg = 'Failed to add report: ${response.statusCode}';
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

        return Future.error(errorMsg);
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error occurred';

      if (e.response != null) {
        final responseData = e.response?.data;
        print('❌ Dio error response: $responseData');

        if (responseData != null && responseData is Map) {
          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            validationErrors.clear();

            final List<String> errorMessages = [];
            errors.forEach((field, messages) {
              String fieldName = _formatFieldName(field);
              if (messages is List) {
                final fieldError = messages.join(', ');
                validationErrors[field] = fieldError;
                errorMessages.add('• $fieldName: $fieldError');
              } else if (messages is String) {
                validationErrors[field] = messages;
                errorMessages.add('• $fieldName: $messages');
              }
            });

            errorMsg = errorMessages.join('\n');
          } else if (responseData['message'] != null) {
            errorMsg = responseData['message'];
          } else {
            errorMsg = 'Server error: ${e.response?.statusCode}';
          }
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

      rethrow;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      isSuccess.value = false;

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to format field names
  String _formatFieldName(String field) {
    final words = field.split('_');
    return words.map((word) =>
    word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
  }

  // Show validation dialog
  void _showValidationDialog() {
    if (validationErrors.isEmpty) return;

    String errorMessage = 'Please fix the following:\n\n';
    validationErrors.forEach((field, message) {
      String fieldName = _formatFieldName(field);
      errorMessage += '• $fieldName: $message\n';
    });

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Validation Error'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            errorMessage,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method to reset states
  void resetState() {
    isLoading.value = false;
    isSuccess.value = false;
    errorMessage.value = '';
    reportResponse.value = null;
    validationErrors.clear();
  }

  // Method to clear error message
  void clearError() {
    errorMessage.value = '';
    validationErrors.clear();
  }

  // Method to check if there's an error
  bool get hasError => errorMessage.value.isNotEmpty;

  // Method to check if operation was successful
  bool get isReportAdded => isSuccess.value;

  // Get validation errors
  Map<String, String> getErrors() => validationErrors;

}




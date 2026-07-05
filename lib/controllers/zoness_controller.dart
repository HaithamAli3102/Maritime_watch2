// controllers/zoness_controller.dart

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/zone_model.dart';
import '../services/api_client.dart';

class ZonessController extends GetxController {
  final ApiClient apiClient = ApiClient();

  // Observable variables
  final RxList<ZoneModel> zones = <ZoneModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ZoneModel?> selectedZone = Rx<ZoneModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  // Fetch all zones from API
  Future<void> fetchZones() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      final response = await apiClient.dio.get('/zones');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        zones.value = data.map((json) => ZoneModel.fromJson(json)).toList();
        isSuccess.value = true;

        if (zones.isNotEmpty) {
          selectedZone.value = zones.first;
        }

        print('✅ Zones fetched successfully: ${zones.length} zones');
      } else {
        throw Exception('Failed to fetch zones: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error occurred';

      if (e.response != null) {
        errorMsg = e.response?.data['message'] ?? 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 404) {
          errorMsg = 'Zones not found. Please try again later.';
        } else if (e.response?.statusCode == 500) {
          errorMsg = 'Server error. Please try again later.';
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

      print('❌ Error fetching zones: $errorMsg');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      isSuccess.value = false;

      Get.snackbar(
        'Error',
        'Failed to load zones',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );

      print('❌ Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get a specific zone by ID
  ZoneModel? getZoneById(String id) {
    try {
      return zones.firstWhere((zone) => zone.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get zone by name
  ZoneModel? getZoneByName(String name) {
    try {
      return zones.firstWhere((zone) => zone.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get zones by type
  List<ZoneModel> getZonesByType(String type) {
    return zones.where((zone) => zone.type == type).toList();
  }

  // Get active zones
  List<ZoneModel> getActiveZones() {
    return zones.where((zone) => zone.status == 'active').toList();
  }

  // Get inactive zones
  List<ZoneModel> getInactiveZones() {
    return zones.where((zone) => zone.status == 'inactive').toList();
  }

  // Select a zone
  void selectZone(ZoneModel zone) {
    selectedZone.value = zone;
  }

  // Refresh zones
  Future<void> refreshZones() async {
    await fetchZones();
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Reset state
  void resetState() {
    isLoading.value = false;
    isSuccess.value = false;
    errorMessage.value = '';
    selectedZone.value = null;
  }

  // Getters
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasZones => zones.isNotEmpty;
  int get zonesCount => zones.length;

}
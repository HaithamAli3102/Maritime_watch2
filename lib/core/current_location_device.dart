
import 'package:get/state_manager.dart';
import 'package:geolocator/geolocator.dart';
class CurrentLocationDevice extends GetxController {

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _determinePosition();
  }

  var  currentLongitude =0.0.obs;
  var  currentLatitude =0.0.obs;

  /// Determine the current position of the device.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // OPTIONAL UPGRADE: Automatically open native GPS settings panel for user convenience
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Optimize: call getCurrentPosition once and store it so you don't ping hardware twice
    final position = await Geolocator.getCurrentPosition();
    currentLatitude.value =position.latitude;
    currentLongitude.value =position.longitude;
    print('Location permission granted : $position');
    return position;
  }

}
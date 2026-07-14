import 'package:dio/dio.dart';

class ApiClient {


  // Or create `Dio` with a `BaseOptions` instance.
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://capably-qualify-economic.ngrok-free.dev/api',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 5),
    // Add this header to bypass the ngrok warning screen
    // headers: {
    //   'ngrok-skip-browser-warning': '69420',
    // },
  ));
}
import 'package:dio/dio.dart';

class ApiClient {


  // Or create `Dio` with a `BaseOptions` instance.
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.pub.dev/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
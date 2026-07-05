import 'package:dio/dio.dart';

class ApiClient {


  // Or create `Dio` with a `BaseOptions` instance.
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://172.18.8.21:8000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
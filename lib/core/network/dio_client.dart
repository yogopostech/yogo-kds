import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yogo_kds/core/constants/urls.dart';
import '../storage/preferences.dart';

class DioClient {
  // static const String baseUrl = 'https://yogo-kds-backend.onrender.com/api';

  // static final Dio _dio = Dio(
  //   BaseOptions(
  //     baseUrl: baseUrl,
  //     connectTimeout: const Duration(seconds: 30),
  //     receiveTimeout: const Duration(seconds: 30),
  //     headers: {'Content-Type': 'application/json'},
  //   ),
  // )..interceptors.add(
  //     InterceptorsWrapper(
  //       onRequest: (options, handler) {
  //         // token থাকলে header এ যোগ করো
  //         final token = Preferences.token;
  //         if (token.isNotEmpty) {
  //           options.headers['Authorization'] = 'Bearer $token';
  //         }
  //         return handler.next(options);
  //       },
  //     ),
  //   );


   static final Dio _dio = Dio(
    BaseOptions(
       baseUrl: Urls.baseUrl, 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = Preferences.token;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log the outgoing request
          debugPrint('┌─────────────────── REQUEST ───────────────────');
          debugPrint('│ ${options.method}  ${options.baseUrl}${options.path}');
          debugPrint('│ Headers: ${options.headers}');
          debugPrint('│ Body: ${options.data}');
          debugPrint('└───────────────────────────────────────────────');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('┌─────────────────── RESPONSE ──────────────────');
          debugPrint('│ Status: ${response.statusCode}');
          debugPrint('│ URL: ${response.requestOptions.uri}');
          debugPrint('│ Data: ${response.data}');
          debugPrint('└───────────────────────────────────────────────');

          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('┌─────────────────── ERROR ─────────────────────');
          debugPrint('│ URL: ${error.requestOptions.uri}');
          debugPrint('│ Status: ${error.response?.statusCode}');
          debugPrint('│ Message: ${error.message}');
          debugPrint('│ Data: ${error.response?.data}');
          debugPrint('└───────────────────────────────────────────────');

          return handler.next(error);
        },
      ),
    );

  static Dio get instance => _dio;
}
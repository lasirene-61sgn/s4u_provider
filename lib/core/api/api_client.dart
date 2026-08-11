import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import '../storage/shared_preference_helper.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static const String baseUrl = ApiConstants.baseUrl;
  late final Dio _dio;

  static const bool isDevPrint = true;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.startsWith('/api') && !options.path.startsWith('http')) {
             options.path = options.path.startsWith('/') ? '/api${options.path}' : '/api/${options.path}';
          }
          final token = await _getToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('\n--- API REQUEST ---');
          print('URL: ${options.baseUrl}${options.path}');
          print('METHOD: ${options.method}');
          if (options.data is FormData) {
            final formData = options.data as FormData;
            print('PAYLOAD (FormData):');
            for (var field in formData.fields) {
              print('  ${field.key}: ${field.value}');
            }
            for (var file in formData.files) {
              print('  [FILE] ${file.key}: ${file.value.filename}');
            }
          } else {
            print('PAYLOAD: ${options.data}');
          }
          print('-------------------\n');
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          print('\n--- API ERROR ---');
          print('URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          print('ERROR MESSAGE: ${error.message}');
          print('ERROR TYPE: ${error.type}');
          print('UNDERLYING ERROR: ${error.error}');
          print('-----------------\n');
          return handler.next(error);
        },
      ),
    );

    if (isDevPrint) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  // ------------------ TOKEN ------------------
  Future<String> _getToken() async {
    final isLoggedIn = SharedPreferenceHelper.getBool("isLoggedIn") ?? false;
    final token = SharedPreferenceHelper.getString("token") ?? "";
    return isLoggedIn && token.isNotEmpty ? token : "";
  }

  // ------------------ GET ------------------
  Future<dynamic> get({
    String? endpoint,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(endpoint ?? '', queryParameters: query);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
         return _handleDioError(e);
      }
      throw Exception("Unexpected error occurred");
    }
  }

  // ------------------ POST ------------------
  Future<dynamic> post({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(endpoint ?? '', data: body);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
         return _handleDioError(e);
      }
      throw Exception("Unexpected error occurred");
    }
  }

  // ------------------ PUT ------------------
  Future<dynamic> put({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(endpoint ?? '', data: body);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
         return _handleDioError(e);
      }
      throw Exception("Unexpected error occurred");
    }
  }

  // ------------------ DELETE ------------------
  Future<dynamic> delete({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.delete(endpoint ?? '', data: body);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
         return _handleDioError(e);
      }
      throw Exception("Unexpected error occurred");
    }
  }


  // ------------------ REQUEST WITH FILES ------------------
  Future<dynamic> requestWithFiles({
    String? endpoint,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? files,
    String method = 'POST',
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        _flattenFields(fields, "").forEach((entry) {
          formData.fields.add(entry);
        });
      }

      _attachFiles(formData, files);

      final response = await _dio.request(
        endpoint ?? '',
        options: Options(method: method.toUpperCase()),
        data: formData,
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ FLATTEN HELPER ------------------
  List<MapEntry<String, String>> _flattenFields(dynamic value, String prefix) {
    List<MapEntry<String, String>> entries = [];

    if (value is Map) {
      value.forEach((k, v) {
        final newPrefix = prefix.isEmpty ? k : '$prefix[$k]';
        entries.addAll(_flattenFields(v, newPrefix));
      });
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        final newPrefix = '$prefix[$i]';
        entries.addAll(_flattenFields(value[i], newPrefix));
      }
    } else if (value != null) {
      entries.add(MapEntry(prefix, value.toString()));
    }

    return entries;
  }

  // ------------------ FILE HELPER ------------------
  void _attachFiles(FormData formData, Map<String, dynamic>? files) {
    if (files == null) return;

    files.forEach((key, value) {
      if (value == null) return;

      final list = value is List ? value : [value];

      for (final item in list) {
        if (item is PlatformFile) {
          final mime = lookupMimeType(item.name) ?? 'application/octet-stream';

          if (kIsWeb && item.bytes != null) {
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromBytes(
                  item.bytes!,
                  filename: item.name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          } else if (!kIsWeb && item.path != null) {
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromFileSync(
                  item.path!,
                  filename: item.name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          }
        } else if (item is String) {
          final file = File(item);
          if (file.existsSync()) {
            final name = item.split('/').last;
            final mime = lookupMimeType(name) ?? 'application/octet-stream';
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromFileSync(
                  item,
                  filename: name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          }
        } else if (item is File) {
          if (item.existsSync()) {
            final name = item.path.split('/').last;
            final mime = lookupMimeType(name) ?? 'application/octet-stream';
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromFileSync(
                  item.path,
                  filename: name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          }
        }
      }
    });
  }

  // ------------------ RESPONSE HANDLER ------------------
  dynamic _handleResponse(Response response) {
    print('--- HANDLE RESPONSE ---');
    print('URL: ${response.requestOptions.uri}');
    print('STATUS: ${response.statusCode}');
    print('PAYLOAD: ${response.requestOptions.data}');
    print('DATA: ${response.data}');
    print('-----------------------');
    
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300) {

      return {
        "status": 1,
        "data": response.data,
      };
    }

    if (status == 401) {
      return {
        "status": 2,
        "message": "Unauthenticated. Please login again.",
      };
    }

    dynamic errorMsg = "Unexpected error";
    if (response.data is Map && response.data['message'] != null) {
      errorMsg = response.data['message'];
    } else if (response.data != null) {
      errorMsg = response.data;
    }

    return {
      "status": 0,
      "message": errorMsg,
    };
  }

  // ------------------ ERROR HANDLER ------------------
  dynamic _handleDioError(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      if ({
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.connectionError,
      }.contains(error.type) || error.error is SocketException) {
        Get.snackbar("Error", "Poor internet connection or server timeout. Please try again.", backgroundColor: const Color(0xFFFFE4E6), colorText: const Color(0xFFE11D48));
        return {
          "status": 0,
          "message": "Poor internet connection or server timeout.",
        };
      }

      dynamic errorMsg = error.message;
      if (response?.data is Map && response?.data['message'] != null) {
        errorMsg = response?.data['message'];
      } else if (response?.data != null) {
        errorMsg = response?.data.toString();
      }

      return {
        "status": 0,
        "message": errorMsg,
      };
    }

    return {
      "status": 0,
      "message": "Unexpected error occurred",
    };
  }
}

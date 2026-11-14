import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin Dio wrapper speaking the versioned REST envelope from architecture.md §6:
/// `{ "data": ..., "meta": { "pagination": ... } }` plus field validation errors.
class ApiClient {
  ApiClient(this.baseUrl)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 25),
          headers: {'Accept': 'application/json', ...apiKeyHeaders},
        ),
      );

  final String baseUrl;
  final Dio _dio;

  String resolveBackendUrl(String url) {
    final uri = Uri.tryParse(url);
    final apiOrigin = Uri.tryParse(baseUrl);
    if (uri == null ||
        apiOrigin == null ||
        !uri.hasScheme ||
        !apiOrigin.hasScheme) {
      return url;
    }

    final isImageRoute = RegExp(
      r'^/api/v1/media/(covers|teachers|audio)/[^/]+$',
    ).hasMatch(uri.path);
    final isAudioStreamRoute = RegExp(r'^/api/v1/audios/[^/]+/stream$')
        .hasMatch(uri.path);

    if ((!isImageRoute && !isAudioStreamRoute) ||
        uri.origin == apiOrigin.origin) {
      return url;
    }

    final pathStart = url.indexOf(uri.path);
    if (pathStart < 0) {
      return url;
    }

    return '${apiOrigin.origin}${url.substring(pathStart)}';
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _request('GET', path, queryParameters: queryParameters);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _request('POST', path, data: data, queryParameters: queryParameters);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      return response.data ?? const <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String, statusCode: status);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('အချိန်ကုန်သွားပါသည်။ ထပ်စမ်းကြည့်ပါ။');
      case DioExceptionType.connectionError:
        return ApiException('ဆက်သွယ်၍ မရပါ။ ကွန်ရက်ကို စစ်ဆေးပါ။');
      default:
        if (status != null && status >= 500) {
          return ApiException('ဆာဗာ အမှားဖြစ်နေပါသည်။', statusCode: status);
        }
        return ApiException('တောင်းဆိုမှု မအောင်မြင်ပါ။', statusCode: status);
    }
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _cachePrefix = 'catalog_response_v1:';
  static const _cacheIndexKey = 'catalog_response_index_v1';
  static const _maxCachedResponses = 40;

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
    final cacheKey = method == 'GET' ? _cacheKey(path, queryParameters) : null;
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      final body = response.data ?? const <String, dynamic>{};
      if (cacheKey != null) {
        await _writeCachedResponse(cacheKey, body);
      }
      return body;
    } on DioException catch (e) {
      if (cacheKey != null && _canUseCachedResponse(e)) {
        final cached = await _readCachedResponse(cacheKey);
        if (cached != null) return cached;
      }
      throw _mapError(e);
    }
  }

  String _cacheKey(String path, Map<String, dynamic>? queryParameters) {
    final sortedQuery = <String, dynamic>{};
    if (queryParameters != null) {
      for (final key in queryParameters.keys.toList()..sort()) {
        sortedQuery[key] = queryParameters[key];
      }
    }
    return '$_cachePrefix${baseUrl.trim()}|$path|${jsonEncode(sortedQuery)}';
  }

  bool _canUseCachedResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == null || statusCode >= 500;
  }

  Future<Map<String, dynamic>?> _readCachedResponse(String key) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(key);
      if (encoded == null) return null;
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // A cache read must never prevent the normal network error from surfacing.
    }
    return null;
  }

  Future<void> _writeCachedResponse(
    String key,
    Map<String, dynamic> body,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(key, jsonEncode(body));

      final keys = preferences.getStringList(_cacheIndexKey) ?? <String>[];
      keys.remove(key);
      keys.add(key);
      while (keys.length > _maxCachedResponses) {
        await preferences.remove(keys.removeAt(0));
      }
      await preferences.setStringList(_cacheIndexKey, keys);
    } catch (_) {
      // Caching is best effort; a storage issue must not fail a successful API call.
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

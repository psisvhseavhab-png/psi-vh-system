import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  String? _authToken;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log or handle unauthorized session expiry
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.post(url, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      final dynamic data = error.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    final msg = error.message ?? '';
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        msg.contains('XMLHttpRequest') ||
        msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Connection refused')) {
      final uriStr = error.requestOptions.uri.toString();
      return 'Connection Failed: Unable to reach $uriStr. Please verify that the backend is running (uvicorn app.main:app --port 8000) or switch API host.';
    }

    if (error.response?.statusCode == 401) {
      return 'Incorrect email or password.';
    }
    if (error.response?.statusCode == 403) {
      return 'Access Denied: You do not have permission for this module.';
    }

    return msg.isNotEmpty ? msg : 'An unexpected network error occurred.';
  }
}


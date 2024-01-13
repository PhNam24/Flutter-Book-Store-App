import 'package:dio/dio.dart';
import 'package:flutter_application_bookstore/data/spref/spref.dart';
import 'package:flutter_application_bookstore/shared/constants.dart';

class BookClient {
  static BaseOptions _options = BaseOptions(
    baseUrl: "http://192.168.1.12:8000",
    receiveDataWhenStatusError: true,
    connectTimeout: Duration(seconds: 60),
    receiveTimeout: Duration(seconds: 60),
  );
  static Dio _dio = Dio(_options);

  // BookClient._internal() {
  //   _dio.interceptors.add(LogInterceptor(responseBody: true));
  // }
  BookClient._internal() {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
        if (token != null) {
          options.headers["Authorization"] = "Bearer " + token;
        }
        return handler.next(options);
      },
    ));
  }

  static final BookClient instance = BookClient._internal();

  Dio get dio => _dio;
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../funcs.dart';
import 'my_http_error.dart';
import 'my_http_response.dart';

typedef ResponseErrorGetter = bool Function(Response value);

class MyHttp {
  MyHttp._();
  static String baseUrl = "";

  static final BaseOptions baseOption = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 30000,
    receiveTimeout: 45000,
    contentType: 'application/json; charset=utf-8',
    responseType: ResponseType.json,
  );

  static final dio = Dio(baseOption);
  // 公共header
  static ValueGetter<Map>? baseHeader;
  // 公共响应处理
  static ValueChanged<MyHttpResponse<dynamic>>? onResponse;
  static ResponseErrorGetter? onResponseHandle;
  // 错误处理
  static ValueChanged<MyHttpError>? onError;

  static init(String _baseUrl) {
    baseUrl = _baseUrl;
    // dio.interceptors.add(LogInterceptor());
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      baseHeader?.call().forEach((key, value) {
        options.headers[key] = value;
      });
      // debug下打印日志
      if (isDebug) {
        var info = "\n🚀 ${options.method}\t: ${options.uri}\n";
        if (options.data is Map) {
          info += "🚀 Data\t: ${jsonEncode(options.data)}";
        }
        // ignore: avoid_print
        print(info);
      }
      handler.next(options);
    }, onResponse: (response, handler) {
      final isError = onResponseHandle?.call(response);
      onResponse?.call(MyHttpResponse.fromDioResponse(response)..request = response.requestOptions.uri);
      if (isError == true) {
        // handler.reject(DioError(requestOptions: response.requestOptions, response: response));
        throw DioError(requestOptions: response.requestOptions, response: response);
      } else {
        handler.next(response);
      }
    }, onError: (DioError e, handler) {
      final err = MyHttpError.fromDioError(e);
      onError?.call(err);
      throw err;
      // handler.next(err);
    }));
  }

  /// get 操作
  static Future<MyHttpResponse<T>> get<T>(
    String path, {
    dynamic params,
    bool hideToast = false,
    bool hideErrorToast = false,
  }) async {
    return request(path, MyHttpType.get, queryParams: params, hideToast: hideToast, hideErrorToast: hideErrorToast);
  }

  ///  post 操作
  static Future<MyHttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    dynamic queryParams,
    bool hideToast = false,
    bool hideErrorToast = false,
  }) async {
    return request(path, MyHttpType.post, data: data, hideToast: hideToast, hideErrorToast: hideErrorToast);
  }

  ///  put 操作
  static Future<MyHttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    dynamic queryParams,
    bool hideToast = false,
    bool hideErrorToast = false,
  }) async {
    return request(path, MyHttpType.put,
        data: data, queryParams: queryParams, hideToast: hideToast, hideErrorToast: hideErrorToast);
  }

  /// delete 操作
  static Future<MyHttpResponse<T>> delete<T>(
    String path, {
    dynamic params,
    bool hideToast = false,
    bool hideErrorToast = false,
  }) async {
    return request(path, MyHttpType.delete, queryParams: params, hideToast: hideToast, hideErrorToast: hideErrorToast);
  }

  static Future<MyHttpResponse<T>> request<T>(
    String path,
    MyHttpType type, {
    dynamic data,
    dynamic queryParams,
    dynamic extra,
    Map<String, dynamic>? headers,
    bool hideToast = false,
    bool hideErrorToast = false,
  }) async {
    assert(baseUrl.isNotEmpty, "请先调用init初始化");
    // 附加数据
    final _extra = {"hideToast": hideToast, "hideErrorToast": hideErrorToast, "data": extra};
    final _options = Options(extra: _extra, headers: headers);

    Response<dynamic> response;
    switch (type) {
      case MyHttpType.post:
        response = await dio
            .post(path, data: data, queryParameters: queryParams, options: _options)
            .catchError((e) => throw e.error);
        break;
      case MyHttpType.put:
        response = await dio
            .put(path, data: data, queryParameters: queryParams, options: _options)
            .catchError((e) => throw e.error);
        break;
      case MyHttpType.delete:
        response =
            await dio.delete(path, queryParameters: queryParams, options: _options).catchError((e) => throw e.error);
        break;
      default:
        response =
            await dio.get(path, queryParameters: queryParams, options: _options).catchError((e) => throw e.error);
    }
    return MyHttpResponse.fromDioResponse(response);
  }
}

enum MyHttpType { get, post, put, delete }

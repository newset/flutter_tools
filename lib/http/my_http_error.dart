import 'package:dio/dio.dart';

import 'my_http_response.dart';

class MyHttpError implements Exception {
  String code = "0";
  String message = "网络异常，请稍后再试！";
  int httpCode = 0;
  bool hideErrorToast = false;
  dynamic response;
  MyHttpError({required this.code, this.message = "开发者自定义错误"});

  MyHttpError.fromDioError(DioError e) {
    final resp = e.response;
    hideErrorToast = e.requestOptions.extra["hideErrorToast"] ?? false;
    if (resp == null) {
      httpCode = 500;
      code = httpCode.toString();
      return;
    } else {
      final respModel = MyHttpResponse.fromDioResponse(resp);
      code = respModel.code;
      httpCode = respModel.httpCode;
      response = respModel;
      message = respModel.message;
    }
  }

  @override
  String toString() {
    return "MyHttpError:{message:$message,httpCode:$code,code:$code}";
  }
}

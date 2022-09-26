import 'package:dio/dio.dart';

class MyHttpResponse<T> {
  // 常用字段
  String code = "-100";
  String message = "数据解析出错";
  bool success = false;
  dynamic data;

  // 附加数据
  dynamic extra;
  // 隐藏toast
  bool hideToast = false;
  bool hideErrorToast = false;
  // http 状态码
  int httpCode = -100;

  dynamic responseData;

  dynamic request;

  MyHttpResponse();

  static const keyData = "data";
  static const keyCode = "code";
  static const keyMessage = "message";
  static const keySuccess = "success";

  MyHttpResponse.fromDioResponse(Response response) {
    hideToast = response.requestOptions.extra["hideToast"] ?? false;
    hideErrorToast = response.requestOptions.extra["hideErrorToast"] ?? false;
    extra = response.requestOptions.extra["data"];
    httpCode = response.statusCode ?? -100;
    responseData = response.data;
    if (response.data is Map) {
      data = response.data[keyData] ?? response.data;
      code = response.data[keyCode]?.toString() ?? httpCode.toString();
      message = response.data[keyMessage]?.toString() ?? message;
      success = response.data[keySuccess] ?? false;
      // 兼容 data 为bool 类型将 success 置为 data
      if (data is bool) {
        if (success) {
          hideToast = true;
        }
        success = data;
      }
    } else {
      success = response.statusCode == 200;
      data = response.data;
    }
  }
}

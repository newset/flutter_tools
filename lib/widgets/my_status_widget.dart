import 'package:flutter/material.dart';

typedef MyWidgetBuilder = Widget Function();
typedef StatusValueWidgetBuilder = Widget Function(MyStatusEnum value);
// 状态枚举
enum MyStatusEnum { normal, loading, emptyData, networkError, other }

// 状态值
abstract class MyStatusValueMixin {
  ValueNotifier<MyStatusEnum> statusNotifier = ValueNotifier<MyStatusEnum>(MyStatusEnum.loading);
  MyStatusEnum get status {
    return statusNotifier.value;
  }

  set status(MyStatusEnum value) {
    statusNotifier.value = value;
  }
}

class MyStatusWidget extends StatelessWidget {
  static StatusValueWidgetBuilder? widget;

  final ValueNotifier<MyStatusEnum> status;
  final WidgetBuilder builder;
  final MyWidgetBuilder? loading;
  final MyWidgetBuilder? emptyData;
  final MyWidgetBuilder? networkError;
  final MyWidgetBuilder? other;
  final ValueChanged<MyStatusEnum>? onTap;
  const MyStatusWidget({
    Key? key,
    required this.status,
    required this.builder,
    this.loading,
    this.emptyData,
    this.networkError,
    this.other,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MyStatusEnum>(
      valueListenable: status,
      builder: (BuildContext context, value, child) {
        switch (value) {
          case MyStatusEnum.loading:
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap?.call(value),
              child: loading?.call() ?? widget?.call(value) ?? const Center(child: CircularProgressIndicator()),
            );
          case MyStatusEnum.emptyData:
            final defaultWidget = Icon(Icons.archive, size: 80, color: Colors.grey[400]);
            return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap?.call(value),
                child: emptyData?.call() ?? widget?.call(value) ?? Center(child: defaultWidget));
          case MyStatusEnum.networkError:
            final defaultWidget = Icon(Icons.wifi_off, size: 80, color: Colors.grey[400]);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap?.call(value),
              child: networkError?.call() ?? widget?.call(value) ?? Center(child: defaultWidget),
            );
          case MyStatusEnum.other:
            final defaultWidget = Icon(Icons.warning, size: 80, color: Colors.grey[400]);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap?.call(value),
              child: other?.call() ?? widget?.call(value) ?? Center(child: defaultWidget),
            );
          default:
            return builder(context);
        }
      },
    );
  }
}

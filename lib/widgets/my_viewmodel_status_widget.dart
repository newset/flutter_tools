import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'my_status_widget.dart';

class BaseViewModel with ChangeNotifier, MyStatusValueMixin {
  onStatusTap(MyStatusEnum value) {}
}

class BaseViewModelStatusWidget<T extends BaseViewModel> extends StatelessWidget {
  const BaseViewModelStatusWidget({
    Key? key,
    required this.builder,
    this.loading,
    this.emptyData,
    this.networkError,
    this.other,
    this.onTap,
  }) : super(key: key);
  final WidgetBuilder builder;
  final MyWidgetBuilder? loading;
  final MyWidgetBuilder? emptyData;
  final MyWidgetBuilder? networkError;
  final MyWidgetBuilder? other;
  final ValueChanged<MyStatusEnum>? onTap;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<T>(context, listen: false);
    return MyStatusWidget(
      onTap: onTap ?? vm.onStatusTap,
      loading: loading,
      emptyData: emptyData,
      networkError: networkError,
      other: other,
      status: vm.statusNotifier,
      builder: builder,
    );
  }
}

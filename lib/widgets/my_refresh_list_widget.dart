import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'my_status_widget.dart';
import 'my_viewmodel_status_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef IndexedValueWidgetBuilder<E> = Widget Function(BuildContext context, int index, E value);

class BaseRefreshListViewModel<T> extends BaseViewModel {
  RefreshController refreshController = RefreshController();
  int page = 1;
  int pageSize = 20;
  List<T> data = [];
  // 标记data列表需要更新
  bool dataShouldRebuild = false;

  // 获取分页参数
  Map<String, dynamic> get pageParams {
    return {"page": page, "size": pageSize};
  }

  loadData([bool refresh = false]) {
    if (refresh) page = 1;
  }

  // 通知data更新
  notifyDataListener() {
    dataShouldRebuild = true;
    notifyListeners();
  }

  // 设置数据状态
  setupData({bool refresh = false, List<T>? value, bool error = false}) {
    if (refresh) {
      // 是刷新
      page = 1;
      data = [];
      refreshController.resetNoData();
      if (value != null && value.isNotEmpty) {
        data = value;
      }
      if (!error) {
        refreshController.refreshCompleted();
        status = data.isEmpty ? MyStatusEnum.emptyData : MyStatusEnum.normal;
      } else {
        refreshController.refreshFailed();
        if (data.isEmpty) {
          status = MyStatusEnum.networkError;
        }
      }
      notifyListeners();
    } else {
      // 加载更多
      if (value != null && value.isNotEmpty) {
        data = data + value;
        notifyListeners();
      }
      if (!error) {
        refreshController.loadComplete();
      } else {
        refreshController.loadFailed();
      }
    }

    // 不管是否刷新都要做的操作
    // 5. 处理是否可以加载更多
    if (value != null && value.length < pageSize) {
      refreshController.loadNoData();
    }
    if (!error) {
      page++;
    }
  }
}

class BaseRefreshListWidget<T extends BaseRefreshListViewModel, E> extends StatelessWidget {
  const BaseRefreshListWidget({
    Key? key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loading,
    this.emptyData,
    this.networkError,
    this.other,
    this.onTap,
    this.enablePullUp = false,
    this.itemExtent,
    this.padding,
  }) : super(key: key);
  final IndexedValueWidgetBuilder<E> itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool enablePullUp;
  final MyWidgetBuilder? loading;
  final MyWidgetBuilder? emptyData;
  final MyWidgetBuilder? networkError;
  final MyWidgetBuilder? other;
  final ValueChanged<MyStatusEnum>? onTap;
  final double? itemExtent;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<T>(context, listen: false);

    return BaseViewModelStatusWidget<T>(
        loading: loading,
        emptyData: emptyData,
        networkError: networkError,
        other: other,
        onTap: onTap,
        builder: (context) {
          return Selector<T, List>(
            shouldRebuild: (o1, o2) {
              if (viewModel.dataShouldRebuild) {
                viewModel.dataShouldRebuild = false;
                return true;
              }
              return o1 != o2;
            },
            selector: (_, vm) => vm.data,
            builder: (context, data, _) {
              return SmartRefresher(
                onRefresh: () => viewModel.loadData(true),
                onLoading: viewModel.loadData,
                controller: viewModel.refreshController,
                enablePullUp: enablePullUp,
                child: (separatorBuilder == null)
                    ? ListView.builder(
                        itemExtent: itemExtent,
                        padding: padding,
                        itemCount: data.length,
                        itemBuilder: (context, index) => itemBuilder(context, index, data[index]),
                      )
                    : ListView.separated(
                        padding: padding,
                        itemCount: data.length,
                        itemBuilder: (context, index) => itemBuilder(context, index, data[index]),
                        separatorBuilder: separatorBuilder!,
                      ),
              );
            },
          );
        });
  }
}

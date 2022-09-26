import 'dart:async';

import 'package:flutter/material.dart';

class NavigatorManager {
  NavigatorManager._();

  static init(BuildContext context) {
    _context = context;
  }

  // 登录页面视图Widget
  static ValueGetter<Widget>? loginPage;

  // 需要登录的页面
  static Set<Type> loginBlocks = {};

  // 阻止到登录页面后的操作
  static ValueGetter<Future<bool>>? loginBlocksHandle;

  static late BuildContext _context;

  // 防止重复push间隔
  static Duration pushDisabledDuration = const Duration(milliseconds: 500);

  // tabbar切换回调
  static ValueChanged<int>? tabbarChanged;

  // push 新页面
  static bool _pushDisabled = false;
  static Future<T?> push<T>(Widget page) async {
    if (_pushDisabled) {
      // print("拦截了重复push");
      return null;
    } else {
      _pushDisabled = true;
      Future.delayed(pushDisabledDuration, () => _pushDisabled = false);
    }

    // 拦截需要登录的页面
    if (loginBlocks.contains(page.runtimeType)) {
      final block = await loginBlocksHandle?.call() ?? false;
      if (block) return null;
    }

    FocusScope.of(_context).requestFocus(FocusNode());
    final settings = RouteSettings(name: page.runtimeType.toString());
    return Navigator.push(_context, MaterialPageRoute(settings: settings, builder: (_) => page));
  }

  /// push并删除页面
  static void pushAndRemove(Widget page, {int removeCount = 1}) {
    var index = 0;
    Navigator.of(_context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) {
        index++;
        return index > removeCount ? true : false;
      },
    );
  }

  // pop 返回
  static pop<T extends Object>({T? data, Type? page, int count = 1}) {
    assert(count > 1 || count < 10, "count 必须大于1小于10");
    if (page == null && count == 1) {
      return Navigator.pop(_context, data);
    }
    int _index = 0;
    return Navigator.popUntil(_context, (predicate) {
      if (predicate.isFirst) return true;
      // 根据数量pop
      if (count > 1) {
        _index++;
        return _index > count ? true : false;
      }
      // 根据类型pop
      final name = predicate.settings.name ?? "";
      // print(name + ":" + page.toString());
      return name == page.toString();
    });
  }

  static void popToRoot([int tabIndex = -1]) {
    if (tabIndex > -1) {
      tabbarChanged?.call(tabIndex);
    }
    Navigator.popUntil(_context, (predicate) {
      return predicate.isFirst;
    });
  }

  // push到登录页面
  static bool _loginPushDisabled = false;
  static Future<bool> login() async {
    if (loginPage == null) return false;
    if (_loginPushDisabled) {
      // print("拦截了重复push");
      return false;
    } else {
      _loginPushDisabled = true;
      Future.delayed(pushDisabledDuration, () => _loginPushDisabled = false);
    }
    final res = await Navigator.of(_context).push(
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => loginPage?.call() ?? Container()),
    );
    return res ?? false;
  }
}

class MyNavigator {
  MyNavigator._();
  // push
  static Future<T?> push<T>(Widget page) => NavigatorManager.push<T>(page);

  // push 并删除
  static void pushAndRemove(Widget page, {int removeCount = 1}) {
    return NavigatorManager.pushAndRemove(page, removeCount: removeCount);
  }

  // pop
  static pop<T extends Object>({T? data, Type? page, int count = 1}) {
    return NavigatorManager.pop<T>(data: data, page: page, count: count);
  }

  // 退到首页
  static void popToRoot([int tabIndex = -1]) {
    return NavigatorManager.popToRoot(tabIndex);
  }

  // 登录页面
  static Future<bool> login() {
    return NavigatorManager.login();
  }
}

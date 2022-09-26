import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_app_bar.dart';

class MyScaffold extends Scaffold {
  MyScaffold({
    Key? key,
    String? title,
    Widget? titleWidget,
    Color? color,
    bool hideAppBar = false,
    PreferredSizeWidget? appBar,
    required Widget body,
    List<Widget>? actions,
    AppBarBackType leadType = AppBarBackType.back,
    WillPopCallback? onWillPop,
    SystemUiOverlayStyle? systemOverlayStyle,
    Widget? floatingActionButton,
    Color? appBarBackgroundColor,
    Color? titleColor,
    bool resizeToAvoidBottomInset = false,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Widget? endDrawer,
    double? drawerEdgeDragWidth,
    bool drawerEnableOpenDragGesture = false,
  }) : super(
          key: key,
          appBar: hideAppBar
              ? null
              : appBar ??
                  MyAppBar(
                    systemOverlayStyle: systemOverlayStyle,
                    leadingType: leadType,
                    onWillPop: onWillPop,
                    actions: actions,
                    title: titleWidget ??
                        MyTitle(
                          title ?? '',
                          style: titleColor != null ? TextStyle(color: titleColor) : null,
                        ),
                    backgroundColor: appBarBackgroundColor,
                  ),
          backgroundColor: color,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
          drawerEdgeDragWidth: drawerEdgeDragWidth,
          drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        );
}

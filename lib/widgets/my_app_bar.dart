import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// appbar 返回按钮类型
enum AppBarBackType { back, close, none }

const double kNavigationBarHeight = 44.0;

// 自定义 AppBar
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    this.title,
    this.leadingType = AppBarBackType.none,
    this.leading,
    this.onWillPop,
    this.systemOverlayStyle,
    this.backgroundColor,
    this.actions,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.titleSpacing = 10,
    this.leadingWidth,
    this.flexibleSpace,
  }) : super(key: key);

  final Widget? title;
  final AppBarBackType leadingType;
  final Widget? leading;
  final WillPopCallback? onWillPop;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final double titleSpacing;
  final double? leadingWidth;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: _leading(),
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      actions: actions,
      elevation: elevation ?? Theme.of(context).appBarTheme.elevation,
      centerTitle: true,
      systemOverlayStyle: systemOverlayStyle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      flexibleSpace: flexibleSpace,
      leadingWidth: leadingWidth,
    );
  }

  _leading() {
    if (leading != null) return leading;
    if (leadingType == AppBarBackType.none) return Container();
    return MyAppBarBack(leadingType, onWillPop: onWillPop);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kNavigationBarHeight);
}

// 自定义返回按钮
class MyAppBarBack extends StatelessWidget {
  const MyAppBarBack(this._backType, {Key? key, this.onWillPop, this.color}) : super(key: key);

  final AppBarBackType? _backType;
  final Color? color;
  final WillPopCallback? onWillPop;
  static Widget? backWidget;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.black;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final willBack = await onWillPop?.call() ?? true;
        if (!willBack) return;
        Navigator.pop(context);
      },
      child: _backType == AppBarBackType.close
          ? Icon(Icons.close, color: color ?? themeColor, size: 24.0)
          : backWidget ?? Icon(Icons.arrow_back_ios, color: color ?? themeColor),
    );
  }
}

class MyTitle extends StatelessWidget {
  final String _title;
  final TextStyle? style;

  const MyTitle(this._title, {Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_title, style: style ?? Theme.of(context).appBarTheme.titleTextStyle);
  }
}

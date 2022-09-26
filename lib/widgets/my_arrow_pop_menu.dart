import 'package:flutter/material.dart';

enum MyArrowPopMenuDirection { up, down }

typedef MyArrowPopMenuBuilder = Widget Function(MyArrowPopMenuDirection driection);
typedef MyArrowPopMenuContentBuilder = Widget Function(OverlayEntry driection);

class MyArrowPopMenu {
  static OverlayEntry? _entry;

  static show(
    BuildContext context, {
    Size arrowSize = const Size(14, 7),
    Color arrowColor = Colors.black87,
    double distance = -3,
    Size contentSize = const Size(120.0, 160),
    double contentMargin = 5.0,
    MyArrowPopMenuContentBuilder? builder,
    MyArrowPopMenuBuilder? arraw,
  }) {
    final box = context.findRenderObject() as RenderBox;
    final topLeftPosition = box.localToGlobal(Offset.zero);

    double contentX = (topLeftPosition.dx + box.size.width / 2.0) - contentSize.width / 2.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final overflowX = (contentX + contentSize.width) - (screenWidth - contentMargin);
    if (overflowX > 0) {
      contentX -= overflowX;
    }
    if (contentX < contentMargin) {
      contentX = contentMargin;
    }

    // 显示上方和下方处理
    double arrowTop = topLeftPosition.dy + box.size.height + distance;
    double contentTop = arrowTop + arrowSize.height;
    MyArrowPopMenuDirection direction = MyArrowPopMenuDirection.up;
    if (MediaQuery.of(context).size.height / 2 < topLeftPosition.dy) {
      arrowTop = topLeftPosition.dy - arrowSize.height - distance;
      contentTop = arrowTop - contentSize.height;
      direction = MyArrowPopMenuDirection.down;
    }

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              child: const SizedBox(width: double.infinity, height: double.infinity),
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => _entry?.remove(),
            ),
            Positioned(
                left: topLeftPosition.dx + box.size.width / 2.0 - arrowSize.width / 2,
                top: arrowTop,
                child: SizedBox(
                  width: arrowSize.width,
                  height: arrowSize.height,
                  child: arraw?.call(direction) ??
                      ClipPath(
                        clipper: MyArrowClipper(direction: direction),
                        child: Container(width: arrowSize.width, height: arrowSize.height, color: arrowColor),
                      ),
                )),
            Positioned(
              left: contentX,
              top: contentTop,
              child: SizedBox(
                child: builder?.call(_entry!),
                width: contentSize.width,
                height: contentSize.height,
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context)?.insert(_entry!);
  }
}

class MyArrowClipper extends CustomClipper<Path> {
  MyArrowClipper({this.direction = MyArrowPopMenuDirection.down, this.radius = 2});

  final MyArrowPopMenuDirection direction;
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();
    if (direction == MyArrowPopMenuDirection.down) {
      path.moveTo(0, 0);
      path.lineTo((size.width / 2) - radius, size.height - radius);

      path.quadraticBezierTo(size.width / 2, size.height, (size.width / 2) + radius, size.height - radius);

      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo((size.width / 2) - radius, radius);

      path.quadraticBezierTo(size.width / 2, 0, (size.width / 2) + radius, radius);

      path.lineTo(size.width, size.height);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

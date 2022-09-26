import 'package:flutter/widgets.dart';

class UnFocusWidget extends StatelessWidget {
  final Widget child;
  const UnFocusWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus,
      child: child,
    );
  }
}

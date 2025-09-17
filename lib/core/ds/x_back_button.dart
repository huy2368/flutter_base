import 'package:flutter/material.dart';

class XBackButton extends StatelessWidget {
  const XBackButton({super.key, this.onTap, this.color});

  final Function? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox();
    return IconButton(
      onPressed: () {
        if (onTap != null) {
          onTap?.call();
        } else {
          Navigator.pop(context);
        }
      },
      style: IconButton.styleFrom(backgroundColor: Colors.transparent),
      icon: Icon(Icons.arrow_back, color: color),
    );
  }
}

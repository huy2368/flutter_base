import 'package:flutter/widgets.dart';
import 'context_extension.dart';

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets withContext(BuildContext context) {
    return EdgeInsets.fromLTRB(
      context.sw(left),
      context.sh(top),
      context.sw(right),
      context.sh(bottom),
    );
  }
}

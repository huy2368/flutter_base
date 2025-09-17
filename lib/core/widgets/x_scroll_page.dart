import 'package:flutter/material.dart';

import '../ds/_xds.dart';
import '../extensions/_extensions.dart';

typedef HeaderBuilder = List<Widget> Function();

class XScrollPage extends StatelessWidget {
  const XScrollPage({
    this.leading,
    this.titleText,
    this.actions,
    required this.body,
    required this.footer,
    super.key,
  });

  final Widget? leading;
  final String? titleText;
  final List<Widget>? actions;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: context.xTheme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
          headerSliverBuilder: (_, scroll) {
            return [
              XSliverAppBar(
                leading: leading,
                title:
                    titleText != null
                        ? Text(
                          titleText!,
                          style: context.titleM.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
                actions: actions,
              ),
            ];
          },
          body: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: footer != null ? 96 : 16,
            ),
            child: SingleChildScrollView(child: body),
          ),
        ),
        floatingActionButton:
            footer != null
                ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    //boxShadow: XBoxShadow.defaultShadow,
                  ),
                  child: footer,
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

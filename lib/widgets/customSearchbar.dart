import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchbar extends PreferredSize {
  final Widget child;
  final double height;

  CustomSearchbar({@required this.child, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      height: preferredSize.height,
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }
}

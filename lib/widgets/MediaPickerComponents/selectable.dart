import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Selectable extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  final int mediaIndex;
  final bool enableOverlay;

  const Selectable({
    Key key,
    @required this.enableOverlay,
    @required this.mediaIndex,
    @required this.isSelected,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 100);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: child,
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOut,
                color: Colors.grey.withOpacity(isSelected ? 0.4 : 0),
              ),
            ),
            enableOverlay
                ? Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300].withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.all(1),
                      child: isSelected
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "$mediaIndex",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  )
                : SizedBox.shrink()
          ],
        );
      },
    );
  }
}

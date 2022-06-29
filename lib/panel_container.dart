import 'package:flutter/material.dart';

import 'panel.dart';

class PanelContainer extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final Panel panel;
  final double leftOffset;
  final double ratio;
  final bool rightSide;
  const PanelContainer(
      {Key? key,
      required this.maxWidth,
      required this.maxHeight,
      required this.panel,
      required this.leftOffset,
      required this.ratio,
      required this.rightSide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftOffset),
      child: Container(
        width: maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        child: Align(
          alignment: rightSide ? Alignment.center : Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: maxWidth * ratio,
              height: maxHeight * ratio,
              child: panel,
            ),
          ),
        ),
      ),
    );
  }
}

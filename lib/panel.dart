import 'package:flutter/material.dart';

class Panel extends StatefulWidget {
  final int index;
  final Color color;
  const Panel({Key? key, required this.index, required this.color})
      : super(key: key);

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  late Offset position;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
        ),
        child: Center(
          child: Text(
            "${widget.index}",
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${widget.index}';
  }
}

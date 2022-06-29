import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class MyExample extends MultiChildRenderObjectWidget {
  // final List<double> offsets;
  final Offset padding;
  MyExample(this.padding, {Key? key, required List<Widget> children})
      : super(key: key, children: children);

  @override
  RenderMyExample createRenderObject(BuildContext context) {
    return RenderMyExample(padding);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderMyExample).reassemble();
    super.updateRenderObject(context, renderObject);
  }
}

class MyExampleParentData extends ContainerBoxParentData<RenderBox> {}

class RenderMyExample extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MyExampleParentData> {
  final Offset padding; // = const;
  late Iterator<Offset> offsetXs;
  // [0, 0.25, 0, 1.25].map((e) => Offset(e * 150 +boxOffset.dx, 200)).toList().iterator;

  RenderMyExample(this.padding);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! MyExampleParentData) {
      child.parentData = MyExampleParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    // print('performLayout $ratios');

    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        // limit children to a max height of 50
        constraints.copyWith(maxHeight: size.height),
      );
    }

    // offsetXs =
    //     ratios.map((e) => Offset(e + padding.dx, padding.dy)).toList().iterator;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // print('paint $ratios');

    for (var child = firstChild; child != null; child = childAfter(child)) {
      // offsetXs.moveNext();
      context.paintChild(child, padding);
    }
    // // print('paint $ratios');
    // offsetXs =
    //     ratios.map((e) => Offset(e + padding.dx, padding.dy)).toList().iterator;
  }
}

import 'package:flutter/material.dart';
import 'package:rotating_carousel/panel.dart';
import 'package:rotating_carousel/render.dart';
import 'dart:math' as math;

import 'panel_container.dart';

class RotatingCarousel extends StatefulWidget {
  final double width;
  final double height;
  final int amount;
  const RotatingCarousel(
      {Key? key,
      required this.amount,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  State<RotatingCarousel> createState() => _RotatingCarouselState();
}

class _RotatingCarouselState extends State<RotatingCarousel>
    with SingleTickerProviderStateMixin {
  List<Panel> panels = [];
  late double panelMaxWidth;
  final double minFactor = 0.8;
  late final List<double> initOffsets;
  final Offset padding = const Offset(10, 100);
  final double overlapRatio = 0.15;
  late List<double> currentOffsets;
  late List<double> initialResizeFactors;
  late List<double> currentResizeFactors;
  bool animateChange = false;
  final double rate = 1.1;
  late AnimationController _animationController;
  late int middleIndex;
  bool isRight = true;
  @override
  void initState() {
    super.initState();
    middleIndex = ((widget.amount) / 2).ceil() - 1;
    panelMaxWidth = getMaxWidth();
    initResizeDimensions();
    currentResizeFactors = initialResizeFactors;
    initOffsets = initializeOffset(initialResizeFactors);
    for (int index = 0; index < widget.amount; index++) {
      panels.add(Panel(
        index: index,
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0),
      ));
    }
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    currentOffsets = initOffsets;
    _animationController.addListener(() => animate());
  }

  @override
  reassemble() {
    super.reassemble();
    middleIndex = ((widget.amount) / 2).ceil() - 1;
    panelMaxWidth = getMaxWidth();
    initResizeDimensions();
    currentResizeFactors = initialResizeFactors;
    initOffsets = initializeOffset(initialResizeFactors);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    currentOffsets = initOffsets;
    _animationController.addListener(() => animate());
    setState(() {});
  }

  initResizeDimensions() {
    if (widget.amount == 1) {
      initialResizeFactors = [1];
    } else if (widget.amount == 2) {
      initialResizeFactors = [minFactor, 1];
    } else {
      var gap = (1 - minFactor) / (middleIndex);
      assert(gap < minFactor, "Increase your min Factor");
      List<double> resizers = List<double>.filled(widget.amount, 1);
      for (var index = middleIndex - 1; index >= 0; index--) {
        resizers[index] = resizers[index + 1] - gap;
      }
      for (var index = middleIndex + 1; index < widget.amount; index++) {
        resizers[index] = resizers[index - 1] - gap;
      }
      initialResizeFactors = resizers;
    }
  }

  // double calculateMinFactor() {
  //   if (widget.amount % 2 == 0) {
  //     return ((((widget.width / panelMaxWidth) - 1) /
  //             ((((widget.amount - 2) / 2) * (1 - overlapRatio)))) -
  //         1);
  //   }
  //   return ((((widget.width / panelMaxWidth) - 1) /
  //           ((1 - overlapRatio) * ((widget.amount + 2) / 2))) +
  //       (4 / (widget.amount + 2)) -
  //       1);
  // }

  double getMaxWidth() {
    if (widget.amount % 2 == 0) {
      return widget.width /
          (((1 - overlapRatio) *
                  (((minFactor + 1) * ((widget.amount) / 2)) - 1)) +
              1);
    }
    return widget.width /
        (((1 - overlapRatio) *
                (((minFactor + 1) * ((widget.amount + 2) / 2)) - 2)) +
            1);
    // return widget.width / ((1 - overlapRatio) * (widget.amount - 1) + 1);
  }

  List<double> initializeOffset(List<double> resizeFactors) {
    List<double> offsets = List<double>.filled(widget.amount, 0);
    offsets[0] = 0;
    for (var amountIndex = 1; amountIndex < widget.amount; amountIndex++) {
      if (amountIndex <= middleIndex) {
        offsets[amountIndex] = offsets[amountIndex - 1] +
            (resizeFactors[amountIndex - 1] *
                panelMaxWidth *
                (1 - overlapRatio));
      } else {
        offsets[amountIndex] = offsets[amountIndex - 1] +
            (resizeFactors[amountIndex - 1] * panelMaxWidth) -
            ((resizeFactors[amountIndex] * panelMaxWidth) * overlapRatio);
      }
    }
    // offsets[middleIndex] = (widget.width - panelMaxWidth) * 0.5;
    // for (var before = middleIndex - 1; before >= 0; before--) {
    //   offsets[before] = offsets[before + 1] -
    //       (resizeFactors[before] * panelMaxWidth * (1 - overlapRatio));
    // }
    // for (var after = middleIndex + 1; after < widget.amount; after++) {
    //   offsets[after] = offsets[after - 1] +
    //       resizeFactors[after - 1] * panelMaxWidth -
    //       resizeFactors[after] * panelMaxWidth * overlapRatio;
    // }
    return offsets;
  }

  // double calculateOverlapRatio(double minFactor) {
  //   if (widget.amount % 2 == 0) {
  //     return 1 -
  //         (((widget.width / panelMaxWidth) - 1) /
  //             ((minFactor + 1) * ((widget.amount - 1) / 4) - 1));
  //   }
  //   return 1 -
  //       (((widget.width / panelMaxWidth) - 1) /
  //           (((widget.amount + 1) / 2) * (minFactor + 1) - 2));
  // }

  @override
  Widget build(BuildContext context) {
    assert(panelMaxWidth * widget.amount > widget.width,
        "Please give a higher maximum width for the widget");
    List<PanelContainer> constrainedWidgets = [];
    for (var panelIndex = 0; panelIndex < widget.amount; panelIndex++) {
      constrainedWidgets.add(PanelContainer(
        maxWidth: panelMaxWidth,
        maxHeight: widget.height,
        panel: panels[panelIndex],
        leftOffset: currentOffsets[panelIndex],
        ratio: currentResizeFactors[panelIndex],
        rightSide: panelIndex > middleIndex,
      ));
    }
    return GestureDetector(
      onPanUpdate: (details) async {
        setState(() {
          isRight = details.delta.dx > 0;
        });
        await _animationController.forward();
      },
      child: Center(
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.teal,
          child: Align(
            alignment: Alignment.centerLeft,
            child: MyExample(
              children: rearrange(constrainedWidgets),
            ),
          ),
        ),
      ),
    );
  }

  animate() {
    var percent = _animationController.value;
    var newOffsets = [];
    var newFactors = [];
    // currentResizeFactors
    for (var index = 0; index < currentOffsets.length; index++) {
      late int next;
      if (isRight) {
        next = (index + 1) % currentOffsets.length;
      } else {
        next = (currentOffsets.length + index - 1) % currentOffsets.length;
      }
      newOffsets.add(((initOffsets[next] - initOffsets[index]) * percent +
              initOffsets[index])
          .abs());
      newFactors.add(
          ((initialResizeFactors[next] - initialResizeFactors[index]) *
                      percent +
                  initialResizeFactors[index])
              .abs());
    }
    // print(newOffsets);
    if (_animationController.isCompleted) {
      _animationController.reset();
      var panelsShiftedLeft = List<dynamic>.filled(currentOffsets.length, null);
      for (var index = 0; index < panels.length; index++) {
        late int next;
        if (isRight) {
          next = (index + 1) % panels.length;
        } else {
          next = (panels.length + index - 1) % panels.length;
        }
        panelsShiftedLeft[next] = panels[index];
      }
      setState(() {
        currentOffsets = [...initOffsets];
        panels = [...panelsShiftedLeft];
        currentResizeFactors = [...initialResizeFactors];
      });
    } else {
      setState(() {
        currentResizeFactors = [...newFactors];
        currentOffsets = [...newOffsets];
      });
    }
  }

  List<Widget> rearrange(List<PanelContainer> panelContainers) {
    List<PanelContainer> rearranged = [];
    for (var currentIndex = 0; currentIndex < middleIndex; currentIndex++) {
      if (isRight) {
        rearranged
            .add(panelContainers[panelContainers.length - 1 - currentIndex]);
        rearranged.add(panelContainers[currentIndex]);
      } else {
        rearranged.add(panelContainers[currentIndex]);
        rearranged
            .add(panelContainers[panelContainers.length - 1 - currentIndex]);
      }
    }
    if (widget.amount % 2 == 0) {
      rearranged.add(panelContainers[middleIndex + 1]);
    }
    return rearranged..add(panelContainers[middleIndex]);
  }
}

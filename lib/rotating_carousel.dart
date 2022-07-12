import 'package:flutter/material.dart';
import 'package:rotating_carousel/panel.dart';
import 'package:rotating_carousel/render.dart';
import 'dart:math' as math;

import 'panel_container.dart';

class RotatingCarousel extends StatefulWidget {
  final double width;
  final double height;
  final List<Widget> panels;
  final double minFactor;
  final double overlapRatio;
  const RotatingCarousel({
    Key? key,
    this.minFactor = 0.9,
    this.overlapRatio = 0.1,
    required this.width,
    required this.height,
    required this.panels,
  }) : super(key: key);

  @override
  State<RotatingCarousel> createState() => _RotatingCarouselState();
}

class _RotatingCarouselState extends State<RotatingCarousel>
    with SingleTickerProviderStateMixin {
  late int amount;
  bool isRight = true;
  late int middleIndex;
  late double panelMaxWidth;
  late List<double> initOffsets;
  late List<Widget> statefulPanels;
  late List<double> currentOffsets;
  late List<double> initialResizeFactors;
  late List<double> currentResizeFactors;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    statefulPanels = widget.panels;
    amount = widget.panels.length;
    middleIndex = ((amount) / 2).ceil() - 1;
    panelMaxWidth = getMaxWidth();
    initResizeDimensions();
    currentResizeFactors = initialResizeFactors;
    initOffsets = initializeOffset(initialResizeFactors);
    // for (int index = 0; index < widget.panels.length; index++) {
    //   panels.add(Panel(
    //     index: index,
    //     color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
    //         .withOpacity(1.0),
    //   ));
    // }
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    currentOffsets = initOffsets;
    _animationController.addListener(() => animate());
  }

  @override
  reassemble() {
    super.reassemble();
    middleIndex = ((amount) / 2).ceil() - 1;
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
    if (amount == 1) {
      initialResizeFactors = [1];
    } else if (amount == 2) {
      initialResizeFactors = [widget.minFactor, 1];
    } else {
      var gap = (1 - widget.minFactor) / (middleIndex);
      assert(gap < widget.minFactor, "Increase your min Factor");
      List<double> resizers = List<double>.filled(amount, 1);
      for (var index = middleIndex - 1; index >= 0; index--) {
        resizers[index] = resizers[index + 1] - gap;
      }
      for (var index = middleIndex + 1; index < amount; index++) {
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
    // if (amount % 2 == 0) {
    return widget.width /
        (((1 - widget.overlapRatio) *
                (((widget.minFactor + 1) * ((amount) / 2)) - 1)) +
            1);
    // }
    // return widget.width /
    //     (((1 - overlapRatio) * (((minFactor + 1) * ((amount + 2) / 2)) - 2)) +
    //         1);
    // return widget.width / ((1 - overlapRatio) * (widget.amount - 1) + 1);
  }

  List<double> initializeOffset(List<double> resizeFactors) {
    List<double> offsets = List<double>.filled(amount, 0);
    offsets[0] = 0;
    for (var amountIndex = 1; amountIndex < amount; amountIndex++) {
      if (amountIndex <= middleIndex) {
        offsets[amountIndex] = offsets[amountIndex - 1] +
            (resizeFactors[amountIndex - 1] *
                panelMaxWidth *
                (1 - widget.overlapRatio));
      } else {
        offsets[amountIndex] = offsets[amountIndex - 1] +
            (resizeFactors[amountIndex - 1] * panelMaxWidth) -
            ((resizeFactors[amountIndex] * panelMaxWidth) *
                widget.overlapRatio);
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
    // assert(panelMaxWidth * amount > widget.width,
    //     "Please give a higher maximum width for the widget");
    List<PanelContainer> constrainedWidgets = [];
    for (var panelIndex = 0; panelIndex < amount; panelIndex++) {
      constrainedWidgets.add(PanelContainer(
        maxWidth: panelMaxWidth,
        maxHeight: widget.height,
        panel: statefulPanels[panelIndex],
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
            child: Center(
              child: MyExample(
                children: rearrange(constrainedWidgets),
              ),
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
      for (var index = 0; index < amount; index++) {
        late int next;
        if (isRight) {
          next = (index + 1) % amount;
        } else {
          next = (amount + index - 1) % amount;
        }
        panelsShiftedLeft[next] = statefulPanels[index];
      }
      setState(() {
        currentOffsets = [...initOffsets];
        statefulPanels = [...panelsShiftedLeft];
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
    if (amount % 2 == 0) {
      rearranged.add(panelContainers[middleIndex + 1]);
    }
    return rearranged..add(panelContainers[middleIndex]);
  }
}

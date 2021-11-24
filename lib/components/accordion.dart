import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef void GM5AccordionChange(int index, GM5AccordionItem item);

class GM5Accordion extends StatefulWidget {
  final List<GM5AccordionItem> items;
  final GM5AccordionChange? onChange;
  final Alignment collapseAlignment;
  final double? animationDuration;
  final Color? headerColor;
  final int initialIndex;
  final bool toggleMode;
  final double spacing;

  const GM5Accordion({
    Key? key,
    required this.items,
    this.onChange,
    this.spacing = 2,
    this.animationDuration,
    this.collapseAlignment = Alignment.topCenter,
    this.headerColor,
    this.initialIndex = 0,
    this.toggleMode = false,
  }) : super(key: key);

  @override
  _GM5AccordionState createState() => _GM5AccordionState();
}

class _GM5AccordionState extends State<GM5Accordion> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final double headersHeight = widget.items.map((e) => e.headerHeight).reduce((a, b) => a + b);
    final double contentHeight = constraints.maxHeight - headersHeight - (widget.items.length - 1) * widget.spacing;
    assert(contentHeight > 0);

    List<Widget> children = [];
    for (int i = 0; i < widget.items.length; i++) {
      children.addAll(_buildItem(i, contentHeight, constraints.maxWidth));
    }

    return Column(
      children: children,
    );
  }

  List<Widget> _buildItem(int index, double contentHeight, double width) {
    final item = widget.items[index];
    final expanded = index == selected;
    return [
      SizedBox(
        width: width,
        height: item.headerHeight,
        child: Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : widget.spacing),
          child: Material(
            type: widget.headerColor == null ? MaterialType.transparency : MaterialType.canvas,
            color: widget.headerColor,
            child: item.headerBuilder != null
                ? item.headerBuilder!(context, () => selectItem(index), expanded)
                : InkWell(
                    onTap: () => selectItem(index),
                    child: item.header,
                  ),
          ),
        ),
      ),
      ClipRect(
        child: AnimatedContainer(
          curve: Curves.easeInOutCubic,
          height: expanded ? contentHeight : 0,
          duration: widget.animationDuration as Duration? ?? Duration(milliseconds: 300),
          child: OverflowBox(
            minWidth: width,
            maxWidth: width,
            minHeight: contentHeight,
            maxHeight: contentHeight,
            alignment: widget.collapseAlignment,
            child: SizedBox(
              width: width,
              height: contentHeight,
              child: item.content,
            ),
          ),
        ),
      ),
    ];
  }

  void selectItem(int index) {
    setState(() {
      if (widget.toggleMode && selected == index) {
        selected = null;
      } else {
        selected = index;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
  }
}

typedef GM5AccordionHeaderBuilder = Widget Function(BuildContext context, VoidCallback onSelect, bool selected);

class GM5AccordionItem {
  final double headerHeight;
  final Widget? header;
  final GM5AccordionHeaderBuilder? headerBuilder;
  final Widget content;

  GM5AccordionItem({this.headerHeight = 44, this.header, required this.content, this.headerBuilder})
      : assert(headerBuilder != null || header != null);
}

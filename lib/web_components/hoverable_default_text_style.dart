import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HoverableDefaultTextStyle extends StatefulWidget {
  final Widget child;
  final TextStyle style;
  final TextStyle hoverStyle;
  final TextAlign textAlign;
  final bool softWrap;
  final TextOverflow overflow;
  final int maxLines;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior textHeightBehavior;
  final Duration duration;
  final Curve curve;

  const HoverableDefaultTextStyle({
    Key key,
    this.style,
    this.hoverStyle,
    this.child,
    this.textAlign,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.curve = Curves.linear,
    this.duration,
  }) : super(key: key);

  @override
  _HoverableDefaultTextStyleState createState() => _HoverableDefaultTextStyleState();
}

class _HoverableDefaultTextStyleState extends State<HoverableDefaultTextStyle> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedDefaultTextStyle(
        style: hovering ? (widget.hoverStyle ?? widget.style.copyWith(fontWeight: FontWeight.bold)) : widget.style,
        child: widget.child,
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        duration: widget.duration ?? Duration(milliseconds: 300),
        curve: widget.curve,
      ),
    );
  }
}

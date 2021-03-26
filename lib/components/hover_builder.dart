import 'package:flutter/material.dart';

typedef HoverWidgetBuilder = Widget Function(BuildContext context, bool hovering);

class HoverBuilder extends StatefulWidget {
  final HoverWidgetBuilder builder;

  const HoverBuilder({Key key, this.builder}) : super(key: key);

  @override
  _HoverBuilderState createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: widget.builder(context, hovering),
    );
  }
}

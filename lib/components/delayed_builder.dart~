import 'package:flutter/material.dart';

class DelayedBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final Duration delay;
  final Duration fadeDuration;
  final Widget placeholder;
  final bool stillLoading;

  const DelayedBuilder(
      {Key key, this.builder, this.delay, this.placeholder, this.fadeDuration, this.stillLoading = false})
      : super(key: key);

  @override
  _DelayedBuilderState createState() => _DelayedBuilderState();
}

class _DelayedBuilderState extends State<DelayedBuilder> {
  bool showContent = false;

  @override
  Widget build(BuildContext context) {
    bool showPlaceholder = widget.stillLoading || !showContent;
    return AnimatedSwitcher(
      child: showPlaceholder ? (widget.placeholder ?? Offstage()) : widget.builder(context),
      duration: widget.fadeDuration ?? Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(
            opacity: animation,
            child: child,
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? Duration(milliseconds: 200)).then((value) => setState(() => showContent = true));
  }
}

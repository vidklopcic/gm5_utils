import 'package:flutter/material.dart';

class DelayedBuilder extends StatefulWidget {
  static Duration defaultDelay = Duration(milliseconds: 200);
  static Duration defaultDuration = Duration(milliseconds: 300);
  static Widget defaultPlaceholder;

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
      child: showPlaceholder
          ? (widget.placeholder ?? DelayedBuilder.defaultPlaceholder ?? Offstage())
          : widget.builder(context),
      duration: widget.fadeDuration ?? DelayedBuilder.defaultDuration,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? DelayedBuilder.defaultDelay).then((value) {
      if (mounted) setState(() => showContent = true);
    });
  }
}

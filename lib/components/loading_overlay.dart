import 'package:flutter/material.dart';

typedef LoadingOverlayBuilder<T> = Widget Function(
    BuildContext context, Future<T?> Function(Future action));

class LoadingOverlay<T> extends StatefulWidget {
  static Duration defaultDuration = Duration(milliseconds: 300);
  static Widget? defaultPlaceholder;
  final LoadingOverlayBuilder<T>? builder;
  final Duration? fadeDuration;
  final Widget? placeholder;
  final Function(Exception)? onError;
  final bool ignorePointer;

  const LoadingOverlay({
    Key? key,
    this.builder,
    this.placeholder,
    this.fadeDuration = Duration.zero,
    this.onError,
    this.ignorePointer = true,
  }) : super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState<T>();
}

class _LoadingOverlayState<T> extends State<LoadingOverlay<T?>> {
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder ?? LoadingOverlay.defaultPlaceholder ?? Offstage();
    return Stack(
      children: [
        widget.builder!(context, _doAction),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: widget.ignorePointer && !showLoading,
            child: AnimatedOpacity(
              duration: widget.fadeDuration ?? LoadingOverlay.defaultDuration,
              opacity: showLoading ? 1 : 0,
              child: placeholder,
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<T?> _doAction(Future action) async {
    if (!mounted) return null;
    setState(() {
      showLoading = true;
    });

    var result;
    try {
      result = await action;
    } catch (e) {
      setState(() {
        showLoading = false;
      });

      if (widget.onError != null)
        widget.onError!(e as Exception);
      else {
        throw (e);
      }
    }

    setState(() {
      showLoading = false;
    });

    return result as T?;
  }
}

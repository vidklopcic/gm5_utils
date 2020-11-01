import 'dart:async';

class EventUtils {
  Map debounceTimeouts = {};

  void debounce(int timeoutMs, Function target, {key, List arguments}) {
    key = key ?? target;
    if (debounceTimeouts.containsKey(key)) {
      debounceTimeouts[key].cancel();
    }

    Timer timer = Timer(Duration(milliseconds: timeoutMs), () {
      Function.apply(target, arguments ?? []);
    });

    debounceTimeouts[key] = timer;
  }

  void throttle(int period, Function target, {key, List arguments}) {
    key = key ?? target;
    if (debounceTimeouts[key]?.isActive ?? false) {
      return;
    }

    Timer timer = Timer(Duration(milliseconds: period), () {
      Function.apply(target, arguments ?? []);
    });

    debounceTimeouts[key] = timer;
  }

  void dropAbove(int period, Function target, {key, List arguments}) {
    key = key ?? target;
    if (debounceTimeouts[key]?.isActive ?? false) {
      return;
    }

    Timer timer = Timer(Duration(milliseconds: period), () => null);
    debounceTimeouts[key] = timer;
    Function.apply(target, arguments ?? []);
  }
}
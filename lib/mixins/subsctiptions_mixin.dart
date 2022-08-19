import 'dart:async';

class SubscriptionsMixin {
  List<StreamSubscription> _subscriptions = [];

  StreamSubscription listen<T>(Stream stream, void Function(T) callback, {Function? onError}) {
    StreamSubscription subscription = stream.listen((item) => callback(item as T), onError: onError);
    _subscriptions.add(subscription);
    return subscription;
  }

  void cancelSubscriptions() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void addSub(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
}

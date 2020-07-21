import 'dart:async';

class SubscriptionsMixin {
  List<StreamSubscription> _subscriptions = [];

  StreamSubscription listen<T>(Stream<T> stream, void Function(T) callback, {Function onError}) {
    StreamSubscription subscription = stream.listen(callback, onError: onError);
    _subscriptions.add(subscription);
    return subscription;
  }

  void cancelSubscriptions() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription?.cancel();
    }
  }
}
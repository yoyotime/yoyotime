import 'domain_event.dart';

typedef EventHandler<T extends DomainEvent> = Future<void> Function(T event);
typedef Subscription = void Function();

class EventBus {
  final Map<Type, List<EventHandler>> _handlers = {};

  Subscription subscribe<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers[T] ??= [];
    _handlers[T]!.add(handler as EventHandler);

    return () {
      _handlers[T]?.remove(handler as EventHandler);
      if (_handlers[T]?.isEmpty ?? false) {
        _handlers.remove(T);
      }
    };
  }

  Future<void> publish(DomainEvent event) async {
    final handlers = _handlers[event.runtimeType];
    if (handlers != null) {
      for (final handler in handlers.toList()) {
        await handler(event);
      }
    }
  }

  void clear() {
    _handlers.clear();
  }

  int get handlerCount => _handlers.values.fold(0, (sum, list) => sum + list.length);
}

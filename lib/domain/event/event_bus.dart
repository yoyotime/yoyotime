import 'domain_event.dart';

typedef EventHandler<T extends DomainEvent> = Future<void> Function(T event);

class EventBus {
  final Map<Type, List<EventHandler>> _handlers = {};

  void subscribe<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers[T] ??= [];
    _handlers[T]!.add(handler as EventHandler);
  }

  Future<void> publish(DomainEvent event) async {
    final handlers = _handlers[event.runtimeType];
    if (handlers != null) {
      for (final handler in handlers) {
        await handler(event);
      }
    }
  }

  void clear() {
    _handlers.clear();
  }
}

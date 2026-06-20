abstract class DomainEvent {
  final DateTime occurredAt;
  final String eventName;

  DomainEvent({String? eventName})
      : occurredAt = DateTime.now(),
        eventName = eventName ?? runtimeType.toString();

  @override
  String toString() => '$eventName(${occurredAt.millisecondsSinceEpoch})';
}

abstract class DomainEvent {
  final DateTime occurredAt;
  late final String eventName;

  DomainEvent({String? eventName}) : occurredAt = DateTime.now() {
    this.eventName = eventName ?? runtimeType.toString();
  }

  @override
  String toString() => '$eventName(${occurredAt.millisecondsSinceEpoch})';
}

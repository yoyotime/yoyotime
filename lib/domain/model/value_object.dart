abstract class ValueObject<T> {
  const ValueObject();

  T get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject<T> &&
          runtimeType == other.runtimeType &&
          props == other.props;

  @override
  int get hashCode => props.hashCode;
}

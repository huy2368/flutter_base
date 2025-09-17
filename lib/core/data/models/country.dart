class Country {
  final String name;
  final String code;
  final String dialCode;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country &&
        other.name == name &&
        other.code == code &&
        other.dialCode == dialCode;
  }

  @override
  int get hashCode => Object.hash(name, code, dialCode);

  @override
  String toString() => 'Country(name: $name, code: $code, dialCode: $dialCode)';
}

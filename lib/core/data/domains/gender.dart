import 'package:json_annotation/json_annotation.dart';


enum EGender {
  @JsonValue(null)
  none,
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}
import 'package:json_annotation/json_annotation.dart';

enum EAppPlatform {
  @JsonValue(null)
  none,
  @JsonValue('android')
  android,
  @JsonValue('ios')
  ios,
  @JsonValue('web')
  web,
}

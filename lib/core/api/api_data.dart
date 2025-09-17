import 'package:json_annotation/json_annotation.dart';

import 'meta.dart';

part 'api_data.g.dart';

@JsonSerializable()
class ApiData {
  final bool status;
  final String? code;
  final dynamic data;
  final Meta? meta;
  final int? statusCode;

  ApiData(
      {this.status = true, this.code, this.data, this.meta, this.statusCode});

  factory ApiData.fromJson(Map<String, dynamic> json) =>
      _$ApiDataFromJson(json);

  Map<String, dynamic> toJson() => _$ApiDataToJson(this);

  @override
  String toString() => toJson().toString();
}

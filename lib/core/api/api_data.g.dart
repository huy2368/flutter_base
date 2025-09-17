// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiData _$ApiDataFromJson(Map<String, dynamic> json) => ApiData(
      status: json['status'] as bool? ?? true,
      code: json['code'] as String?,
      data: json['data'],
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ApiDataToJson(ApiData instance) => <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'data': instance.data,
      'meta': instance.meta?.toJson(),
      'statusCode': instance.statusCode,
    };

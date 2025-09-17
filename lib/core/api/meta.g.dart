// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      message: json['message'] as String?,
      errors: json['errors'],
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'message': instance.message,
      'errors': instance.errors,
    };

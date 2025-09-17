// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file


part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  provider: json['provider'] as String?,
  role: json['role'] as String?,
  status: json['status'] as bool? ?? false,
  avatar: json['avatar'] as String?,
  country: json['country'] as String?,
  fullName: json['fullName'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  gender: $enumDecodeNullable(_$EGenderEnumMap, json['gender']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'provider': instance.provider,
  'role': instance.role,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'avatar': instance.avatar,
  'country': instance.country,
  'fullName': instance.fullName,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'gender': _$EGenderEnumMap[instance.gender],
};

const _$EGenderEnumMap = {
  EGender.none: null,
  EGender.male: 'male',
  EGender.female: 'female',
  EGender.other: 'other',
};

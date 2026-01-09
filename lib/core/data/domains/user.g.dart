// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  provider: json['provider'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: json['status'] as bool? ?? false,
  avatar: json['avatar'] as String?,
  country: json['country'] as String?,
  fullName: json['fullName'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  gender: $enumDecodeNullable(_$EGenderEnumMap, json['gender']),
  phoneNumber: json['phoneNumber'] as String?,
  timezone: json['timezone'] as String?,
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
  'password': instance.password,
  'provider': instance.provider,
  'roles': instance.roles.map((e) => e.toJson()).toList(),
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'avatar': instance.avatar,
  'country': instance.country,
  'fullName': instance.fullName,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'gender': _$EGenderEnumMap[instance.gender],
  'phoneNumber': instance.phoneNumber,
  'timezone': instance.timezone,
};

const _$EGenderEnumMap = {
  EGender.none: null,
  EGender.male: 'male',
  EGender.female: 'female',
  EGender.other: 'other',
};

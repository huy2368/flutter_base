// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file


part of 'refresh_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshTokenResponse _$RefreshTokenResponseFromJson(
  Map<String, dynamic> json,
) => RefreshTokenResponse(
  token: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  tokenExpires: (json['tokenExpires'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RefreshTokenResponseToJson(
  RefreshTokenResponse instance,
) => <String, dynamic>{
  'token': instance.token,
  'refreshToken': instance.refreshToken,
  'tokenExpires': instance.tokenExpires,
};

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'refresh_token_response.g.dart';

@JsonSerializable()
class RefreshTokenResponse {
  const RefreshTokenResponse({
    required this.token,
    required this.refreshToken,
    this.tokenExpires = 0,
  });

  final String token;
  final String refreshToken;
  final int tokenExpires;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);

  RefreshTokenResponse copyWith({
    String? token,
    String? refreshToken,
    int? tokenExpires,
  }) =>
      RefreshTokenResponse(
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken,
        tokenExpires: tokenExpires ?? this.tokenExpires,
      );

  @override
  String toString() => jsonEncode(toJson());
}

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../domains/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.refreshToken,
    this.tokenExpires = 0,
    required this.user,
    this.createdAt,
    this.updatedAt,
  });

  final String token;
  final String refreshToken;
  final int tokenExpires;
  final User user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  AuthResponse copyWith({
    String? token,
    String? refreshToken,
    int? tokenExpires,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AuthResponse(
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken,
        tokenExpires: tokenExpires ?? this.tokenExpires,
        user: user ?? this.user,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => jsonEncode(toJson()).toString();
}

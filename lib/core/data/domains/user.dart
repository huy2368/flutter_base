import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'gender.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
    this.id,
    this.email,
    this.provider,
    this.role,
    this.status = false,
    this.avatar,
    this.country,
    this.fullName,
    this.firstName,
    this.lastName,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? email;
  final String? provider;
  final String? role;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatar;
  final String? country;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final EGender? gender;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

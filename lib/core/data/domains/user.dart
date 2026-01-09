import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'gender.dart';
import 'role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
    this.id,
    this.email,
    this.password,
    this.provider,
    this.roles = const [],
    this.status = false,
    this.avatar,
    this.country,
    this.fullName,
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? email;
  final String? password;
  final String? provider;
  final List<Role> roles;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatar;
  final String? country;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final EGender? gender;
  final String? phoneNumber;
  final String? timezone;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

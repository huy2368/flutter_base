import 'dart:io';

import 'package:retrofit/retrofit.dart';

import '../domains/_domains.dart';
import '../models/_models.dart';

abstract class LoginProvider {
  Future<AuthResponse?> login({
    @Field('email') required String email,
    @Field('password') required String password,
  });

  Future<AuthResponse?> loginGoogle({
    @Field('idToken') required String idToken,
  });

  Future<AuthResponse?> loginApple({
    @Field('identityToken') required String? identityToken,
    @Field('authorizationCode') required String authorizationCode,
    @Field('email') required String? email,
  });

  Future<User?> me();

  @MultiPart()
  Future<User?> patchMe({
    @Part(name: 'file', contentType: 'image/jpeg') File? file,
    @Part(name: 'fullName') String? fullName,
    @Part(name: 'gender') String? gender,
    @Part(name: 'country') String? countryCode,
    @Part(name: 'oldPassword') String? oldPassword,
    @Part(name: 'password') String? password,
    @Part(name: 'confirm_password') String? confirmPassword,
  });

  Future<RefreshTokenResponse?> refreshToken();
}

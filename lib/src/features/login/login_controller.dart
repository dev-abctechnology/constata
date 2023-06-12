import 'dart:convert';

import 'package:constata/src/features/login/login_repository.dart';
import 'package:constata/src/shared/constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final LoginRepository repository;

  LoginController(
    this.repository,
  );

  Future<void> generateToken(String username, String password) async {
    final response = await repository.generateToken(username, password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'authentication', jsonEncode({"user": username, "password": password}));
    await prefs.setString('token', response);
  }

  Future<Map<String, dynamic>> fetchUserSigned(String username) async {
    final response = await repository.fetchUserSigned(username);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(response));

    return response;
  }

  Future<Map<String, dynamic>> pegarParceiroDeNegocio(String username) async {
    final response = await repository.pegarParceiroDeNegocio(username);
    return response;
  }

  Future<List> fetchObraData(String username) async {
    final response = await repository.fetchObras(username);
    return response;
  }
}

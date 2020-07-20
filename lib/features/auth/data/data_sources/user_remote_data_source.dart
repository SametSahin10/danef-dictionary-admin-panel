import 'dart:convert';

import 'package:danef_dictionary_admin_panel/core/config/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

abstract class UserRemoteDataSource {
  Future<String> signIn(String email, String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<String> signIn(String username, String password) async {
    final baseUrl = DotEnv().env['BASE_URL'];
    final requestBody = {
      "email": "$username",
      "password": "$password",
    };
    final url = baseUrl + Constants.signInString;
    try {
      final response = await http.post(
        url,
        headers: {io.HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == io.HttpStatus.ok) {
        final responseBody = json.decode(response.body);
        final status = responseBody['status'];
        if (status == true) {
          print('Signed in succesfully');
          print('status code ${response.statusCode}');
          print('response body: ${response.body}');
          final token = responseBody['account']['token'];
          print('token: $token');
          return token;
        } else {
          print('Signing in failed');
          print('status code ${response.statusCode}');
          print('response body: ${response.body}');
          return null;
        }
      } else {
        print('Signing in failed');
        print('status code ${response.statusCode}');
        print('response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('exception occured while signing in ${e.toString()}');
      return null;
    }
  }
}

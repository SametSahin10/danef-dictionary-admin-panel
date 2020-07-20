import 'dart:convert';
import 'dart:html';

import 'package:danef_dictionary_admin_panel/core/config/constants.dart';
import 'package:http/http.dart' as http;

abstract class UserRemoteDataSource {
  Future<String> signIn(String email, String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<String> signIn(String username, String password) async {
    final baseUrl = Constants.baseUrl;
    final requestBody = {
      "email": "$username",
      "password": "$password",
    };
    final url = baseUrl + Constants.signInString;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == HttpStatus.ok) {
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

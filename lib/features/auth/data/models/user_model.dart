import 'package:meta/meta.dart';

import '../../domain/entities/user.dart';

class UserModel extends User {
  final String email;
  final String password;

  UserModel({
    @required this.email,
    this.password,
  }) : super(email: email);
}
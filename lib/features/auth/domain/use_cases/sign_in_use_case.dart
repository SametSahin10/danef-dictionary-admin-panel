import 'package:meta/meta.dart';

import '../../../../core/use_case/use_case.dart';
import '../repositories/user_repository.dart';

class SignInUseCase implements UseCase<String, UserParams> {
  final UserRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<String> call(UserParams params) async {
    return await repository.signIn(params.email, params.password);
  }
}

class UserParams {
  final String email;
  final String password;

  UserParams({
    @required this.email,
    @required this.password,
  });
}

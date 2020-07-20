abstract class UserRepository {
  Future<String> signIn(String email, String password);
}
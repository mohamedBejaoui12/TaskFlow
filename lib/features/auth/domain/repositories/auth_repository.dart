import '../../data/models/user_model.dart';

abstract class AuthRepository {
  List<UserModel> getAllUsers();
  UserModel? findUserById(String id);
  UserModel? login(String email, String password);
  UserModel update(UserModel user);
  UserModel register({
    required String name,
    required String email,
    required String password,
    required String avatarColor,
  });
}

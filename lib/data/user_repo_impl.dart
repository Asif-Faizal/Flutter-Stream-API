import '../domain/user_entity.dart';
import '../domain/user_repo.dart';
import 'user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<User>> getUsersStream() {
    return remoteDataSource.getUsersStream().map(
      (userModels) => userModels.map((model) => User(name: model.name, email: model.email)).toList(),
    );
  }
}

import 'user_entity.dart';
import 'user_repo.dart';

class GetUsersStream {
  final UserRepository userRepository;

  GetUsersStream(this.userRepository);

  Stream<List<User>> call() {
    return userRepository.getUsersStream();
  }
}

import 'dart:async';
import 'user_entity.dart';

abstract class UserRepository {
  Stream<List<User>> getUsersStream();
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../domain/get_user_stream.dart';
import '../domain/user_entity.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersStream getUsersStream;

  UserBloc(this.getUsersStream) : super(UserInitial()) {
    on<UserStreamRequested>(_onUserStreamRequested);
  }

  // Event handler
  Future<void> _onUserStreamRequested(
    UserStreamRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserStreamLoading()); // Emit loading state

    try {
      await for (var users in getUsersStream()) {
        emit(UserStreamLoaded(users: users)); // Emit loaded state with users
      }
    } catch (e) {
      emit(UserStreamError(message: e.toString())); // Emit error state if any
    }
  }
}
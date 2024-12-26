part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserStreamLoading extends UserState {}

class UserStreamLoaded extends UserState {
  final List<User> users;

  UserStreamLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserStreamError extends UserState {
  final String message;

  UserStreamError({required this.message});

  @override
  List<Object?> get props => [message];
}
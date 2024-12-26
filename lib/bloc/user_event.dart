part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserStreamRequested extends UserEvent {}
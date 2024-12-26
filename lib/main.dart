import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/user_bloc.dart';
import 'data/user_datasource.dart';
import 'data/user_repo_impl.dart';
import 'domain/get_user_stream.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userRemoteDataSource =
        UserRemoteDataSourceImpl(baseUrl: 'http://127.0.0.1:3000');
    final userRepository =
        UserRepositoryImpl(remoteDataSource: userRemoteDataSource);
    final getUsersStream = GetUsersStream(userRepository);
    final userBloc = UserBloc(getUsersStream);
    return BlocProvider(
      create: (context) => userBloc,
      child: MaterialApp(
        home: UserScreen(),
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().add(UserStreamRequested());

    return Scaffold(
      appBar: AppBar(title: Text('Users Stream')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserStreamLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserStreamLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            );
          } else if (state is UserStreamError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return Center(child: Text('No users available.'));
        },
      ),
    );
  }
}

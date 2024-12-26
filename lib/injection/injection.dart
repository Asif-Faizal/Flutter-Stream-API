import 'package:get_it/get_it.dart';

import '../bloc/user_bloc.dart';
import '../data/user_datasource.dart';
import '../data/user_repo_impl.dart';
import '../domain/get_user_stream.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  print('Registering dependencies...');

  // Register the data source
  print('Registering UserRemoteDataSourceImpl...');
  getIt.registerLazySingleton<UserRemoteDataSourceImpl>(
    () => UserRemoteDataSourceImpl(baseUrl: 'http://localhost:3000'),
  );

  // Register the repository implementation
  print('Registering UserRepositoryImpl...');
  getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(remoteDataSource: getIt()),
  );

  // Register the use case
  print('Registering GetUsersStream...');
  getIt.registerLazySingleton<GetUsersStream>(
    () => GetUsersStream(getIt()),
  );

  // Register the bloc
  print('Registering UserBloc...');
  getIt.registerLazySingleton<UserBloc>(
    () => UserBloc(getIt()),
  );

  print('Dependencies registered');
}

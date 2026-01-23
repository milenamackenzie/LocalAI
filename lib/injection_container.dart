import 'package:get_it/get_it.dart';
import 'core/database/local_database.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/bookmark_repository_impl.dart';
import 'data/repositories/preference_repository_impl.dart';
import 'data/repositories/review_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/bookmark_repository.dart';
import 'domain/repositories/preference_repository.dart';
import 'domain/repositories/review_repository.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/bookmark_bloc.dart';
import 'presentation/blocs/review_bloc.dart';
import 'presentation/blocs/theme_bloc.dart';
import 'presentation/blocs/user_hub_bloc.dart';
import 'presentation/blocs/bookmark_bloc.dart';
import 'core/database/local_database.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/preference_repository.dart';
import 'domain/repositories/bookmark_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/preference_repository_impl.dart';
import 'data/repositories/bookmark_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  sl.registerFactory(() => ThemeBloc());
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => UserHubBloc(preferenceRepository: sl()));
  sl.registerFactory(() => BookmarkBloc(bookmarkRepository: sl()));

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PreferenceRepository>(
    () => PreferenceRepositoryImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(apiClient: sl(), localDatabase: sl()),
  );

  //! Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => LocalDatabase());

  //! External
  sl.registerLazySingleton(() => Dio());
}


import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/datasources/remote/authentication_remote_data_source.dart';
import '../../data/datasources/remote/banner_remote_data_source.dart';
import '../../data/datasources/remote/help_request_remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/authentication_repository_impl.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../data/repositories/help_request_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/repositories/help_request_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/routing_service.dart';
import '../../core/utils/network_manager.dart';
import '../../data/repositories/user/user_repository_adapter.dart';

/// GetIt instance - Service Locator
final getIt = GetIt.instance;

/// Initialize dependency injection container
Future<void> init() async {
  // ============================
  // Services
  // ============================
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<RoutingService>(() => RoutingService());
  getIt.registerLazySingleton<NetworkManager>(() => NetworkManager());
  
  // ============================
  // Adapters (for backward compatibility)
  // ============================
  getIt.registerLazySingleton<UserRepositoryAdapter>(() => UserRepositoryAdapter());

  // ============================
  // Data Sources
  // ============================
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<BannerRemoteDataSource>(
    () => BannerRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<HelpRequestRemoteDataSource>(
    () => HelpRequestRemoteDataSourceImpl(),
  );

  // ============================
  // Repositories - Register as Interface
  // ============================
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(getIt<AuthenticationRemoteDataSource>()),
  );
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(getIt<BannerRemoteDataSource>()),
  );
  getIt.registerLazySingleton<HelpRequestRepository>(
    () => HelpRequestRepositoryImpl(getIt<HelpRequestRemoteDataSource>()),
  );
}


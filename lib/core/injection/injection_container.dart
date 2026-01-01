import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/datasources/remote/authentication_remote_data_source.dart';
import '../../data/datasources/remote/banner_remote_data_source.dart';
import '../../data/datasources/remote/help_request_remote_data_source.dart';
import '../../data/datasources/remote/support_remote_data_source.dart';
import '../../data/datasources/local/support_local_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/authentication_repository_impl.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../data/repositories/help_request_repository_impl.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../data/repositories/alerts/alert_repository.dart' as alert_impl;
import '../../data/repositories/shelters/shelter_repository.dart' as shelter_impl;
import '../../data/repositories/donations/donation_repository.dart' as donation_impl;
import '../../data/repositories/donations/donation_plan_repository.dart' as donation_plan_impl;
import '../../data/repositories/area_coordinators/area_coordinator_repository.dart' as area_coordinator_impl;
import '../../data/repositories/news/news_repository.dart' as news_impl;
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/repositories/help_request_repository.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/repositories/shelter_repository.dart';
import '../../domain/repositories/donation_repository.dart';
import '../../domain/repositories/donation_plan_repository.dart';
import '../../domain/repositories/area_coordinator_repository.dart';
import '../../domain/repositories/news_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/routing_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/smart_notification_service.dart';
import '../../data/services/alert_seed_service.dart';
import '../../data/services/ai_service_client.dart';
import '../../data/services/ai_service_monitor.dart';
import '../../domain/services/alert_scoring_service.dart';
import '../../domain/services/alert_deduplication_service.dart';
import '../../domain/services/hybrid_alert_scoring_service.dart';
import '../../core/utils/network_manager.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/user/user_repository_adapter.dart';
import '../../presentation/features/admin/controllers/admin_alerts_controller.dart';

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
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // ============================
  // Smart Alert System Services
  // ============================
  // AlertScoringService - Multi-factor Severity Scoring (Fallback)
  getIt.registerLazySingleton<AlertScoringService>(
    () => const AlertScoringService(),
  );
  
  // AI Service Client - Connection to Python AI Service
  getIt.registerLazySingleton<AIServiceClient>(
    () => AIServiceClient(
      baseUrl: aiServiceBaseUrl,
    ),
  );
  
  // AI Service Monitor - Health checking and metrics
  getIt.registerLazySingleton<AIServiceMonitor>(
    () => AIServiceMonitor(
      aiService: getIt<AIServiceClient>(),
    )..startMonitoring(), // Auto-start monitoring
  );
  
  // Hybrid Alert Scoring Service - AI Primary + Rule-based Fallback
  getIt.registerLazySingleton<HybridAlertScoringService>(
    () => HybridAlertScoringService(
      ruleBasedService: getIt<AlertScoringService>(),
      aiService: getIt<AIServiceClient>(),
      useAI: enableAiScoring,
    ),
  );
  
  // AlertDeduplicationService - Jaccard Similarity
  getIt.registerLazySingleton<AlertDeduplicationService>(
    () => const AlertDeduplicationService(),
  );
  
  // SmartNotificationService - Batching & Cooldown
  getIt.registerLazySingleton<SmartNotificationService>(
    () => SmartNotificationService(),
  );
  
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
  getIt.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<SupportLocalDataSource>(
    () => SupportLocalDataSourceImpl(),
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
  getIt.registerLazySingleton<AlertRepository>(
    () => alert_impl.AlertRepositoryImpl(),
  );
  getIt.registerLazySingleton<ShelterRepository>(
    () => shelter_impl.ShelterRepositoryImpl(),
  );
  getIt.registerLazySingleton<DonationRepository>(
    () => donation_impl.DonationRepositoryImpl(),
  );
  getIt.registerLazySingleton<DonationPlanRepository>(
    () => donation_plan_impl.DonationPlanRepositoryImpl(),
  );
  getIt.registerLazySingleton<AreaCoordinatorRepository>(
    () => area_coordinator_impl.AreaCoordinatorRepositoryImpl(),
  );
  getIt.registerLazySingleton<NewsRepository>(
    () => news_impl.NewsRepositoryImpl(),
  );
  getIt.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(
      remoteDataSource: getIt<SupportRemoteDataSource>(),
      localDataSource: getIt<SupportLocalDataSource>(),
    ),
  );

  // ============================
  // Services that depend on Repositories
  // ============================
  // AlertSeedService depends on AlertRepository, so register it after repositories
  getIt.registerLazySingleton<AlertSeedService>(() => AlertSeedService());

  // ============================
  // Controllers
  // ============================
  // Register as factory to create new instances each time
  getIt.registerFactory<AdminAlertsController>(
    () => AdminAlertsController(),
  );
}


import 'package:get/get.dart';
import '../../core/injection/injection_container.dart' as di;
import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/datasources/remote/authentication_remote_data_source.dart';
import '../../data/datasources/remote/banner_remote_data_source.dart';
import '../../data/datasources/remote/help_request_remote_data_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/repositories/help_request_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/re_authenticate_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/save_user_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../../domain/usecases/get_all_banners_usecase.dart';
import '../../domain/usecases/upload_banners_usecase.dart';
import '../../domain/usecases/create_help_request_usecase.dart';
import '../../domain/usecases/get_help_requests_usecase.dart';
import '../../domain/usecases/get_help_requests_by_user_usecase.dart';
import '../../domain/usecases/update_help_request_status_usecase.dart';
import '../../core/utils/network_manager.dart';
import '../../data/services/location_service.dart';

/// App Bindings - Dependency Injection cho Clean Architecture
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Network Manager
    Get.put(NetworkManager());
    
    // Services
    Get.put(LocationService(), permanent: true);

    // Data Sources - Register in GetX for backward compatibility
    Get.lazyPut<UserRemoteDataSource>(() => di.getIt<UserRemoteDataSource>());
    Get.lazyPut<AuthenticationRemoteDataSource>(() => di.getIt<AuthenticationRemoteDataSource>());
    Get.lazyPut<BannerRemoteDataSource>(() => di.getIt<BannerRemoteDataSource>());
    Get.lazyPut<HelpRequestRemoteDataSource>(() => di.getIt<HelpRequestRemoteDataSource>());
    
    // Repositories - Use get_it (registered as interface)
    Get.lazyPut<UserRepository>(() => di.getIt<UserRepository>());
    Get.lazyPut<AuthenticationRepository>(() => di.getIt<AuthenticationRepository>());
    Get.lazyPut<BannerRepository>(() => di.getIt<BannerRepository>());
    Get.lazyPut<HelpRequestRepository>(() => di.getIt<HelpRequestRepository>());
    
    // Authentication Use Cases - Using get_it for repository
    Get.lazyPut(() => LoginUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => RegisterUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => SignInWithGoogleUseCase(di.getIt<AuthenticationRepository>()));
    // LogoutUseCase - tạo ngay để đảm bảo luôn sẵn sàng
    Get.put(LogoutUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => SendEmailVerificationUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => SendPasswordResetUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => ReAuthenticateUseCase(di.getIt<AuthenticationRepository>()));
    Get.lazyPut(() => DeleteAccountUseCase(di.getIt<AuthenticationRepository>()));
    
    // User Use Cases - Using get_it for repository
    Get.lazyPut(() => GetCurrentUserUseCase(di.getIt<UserRepository>()));
    Get.lazyPut(() => SaveUserUseCase(di.getIt<UserRepository>()));
    Get.lazyPut(() => UpdateUserUseCase(di.getIt<UserRepository>()));
    Get.lazyPut(() => UploadImageUseCase(di.getIt<UserRepository>()));
    
    // Banner Use Cases - Using get_it for repository
    Get.lazyPut(() => GetAllBannersUseCase(di.getIt<BannerRepository>()));
    Get.lazyPut(() => UploadBannersUseCase(di.getIt<BannerRepository>()));
    
    // Help Request Use Cases - Using get_it for repository
    Get.lazyPut(() => CreateHelpRequestUseCase(di.getIt<HelpRequestRepository>()));
    Get.lazyPut(() => GetHelpRequestsUseCase(di.getIt<HelpRequestRepository>()));
    Get.lazyPut(() => GetHelpRequestsByUserUseCase(di.getIt<HelpRequestRepository>()));
    Get.lazyPut(() => UpdateHelpRequestStatusUseCase(di.getIt<HelpRequestRepository>()));
  }
}



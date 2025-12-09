import 'package:get/get.dart';
import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/datasources/remote/authentication_remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/authentication_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/authentication_repository.dart';
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
import '../../data/datasources/remote/banner_remote_data_source.dart';
import '../../data/datasources/remote/help_request_remote_data_source.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../data/repositories/help_request_repository_impl.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/repositories/help_request_repository.dart';
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

    // Data Sources
    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSourceImpl());
    Get.lazyPut<AuthenticationRemoteDataSource>(() => AuthenticationRemoteDataSourceImpl());
    Get.lazyPut<BannerRemoteDataSource>(() => BannerRemoteDataSourceImpl());
    Get.lazyPut<HelpRequestRemoteDataSource>(() => HelpRequestRemoteDataSourceImpl());
    
    // Repositories
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(Get.find()));
    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepositoryImpl(Get.find()));
    Get.lazyPut<BannerRepository>(() => BannerRepositoryImpl(Get.find()));
    Get.lazyPut<HelpRequestRepository>(() => HelpRequestRepositoryImpl(Get.find()));
    
    // Authentication Use Cases
    Get.lazyPut(() => LoginUseCase(Get.find()));
    Get.lazyPut(() => RegisterUseCase(Get.find()));
    Get.lazyPut(() => SignInWithGoogleUseCase(Get.find()));
    // LogoutUseCase - tạo ngay để đảm bảo luôn sẵn sàng
    Get.put(LogoutUseCase(Get.find<AuthenticationRepository>()));
    Get.lazyPut(() => SendEmailVerificationUseCase(Get.find()));
    Get.lazyPut(() => SendPasswordResetUseCase(Get.find()));
    Get.lazyPut(() => ReAuthenticateUseCase(Get.find()));
    Get.lazyPut(() => DeleteAccountUseCase(Get.find()));
    
    // User Use Cases
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find()));
    Get.lazyPut(() => SaveUserUseCase(Get.find()));
    Get.lazyPut(() => UpdateUserUseCase(Get.find()));
    Get.lazyPut(() => UploadImageUseCase(Get.find()));
    
    // Banner Use Cases
    Get.lazyPut(() => GetAllBannersUseCase(Get.find()));
    Get.lazyPut(() => UploadBannersUseCase(Get.find()));
    
    // Help Request Use Cases
    Get.lazyPut(() => CreateHelpRequestUseCase(Get.find()));
    Get.lazyPut(() => GetHelpRequestsUseCase(Get.find()));
    Get.lazyPut(() => GetHelpRequestsByUserUseCase(Get.find()));
    Get.lazyPut(() => UpdateHelpRequestStatusUseCase(Get.find()));
  }
}



import 'dart:async';
import 'dart:convert';
import 'package:cuutrobaolu/domain/usecases/get_help_requests_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/get_help_requests_by_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/update_help_request_status_usecase.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:cuutrobaolu/data/repositories/help/help_repository_inmemory.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/supporter_modal.dart';
import 'package:cuutrobaolu/core/constants/enums.dart' as core;
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class HelpController extends GetxController {
  static HelpController get to => Get.find();

  // Use Cases - Clean Architecture (lazy getters để tránh LateInitializationError)
  GetHelpRequestsUseCase get _getHelpRequestsUseCase => Get.find<GetHelpRequestsUseCase>();
  GetHelpRequestsByUserUseCase get _getHelpRequestsByUserUseCase => Get.find<GetHelpRequestsByUserUseCase>();
  UpdateHelpRequestStatusUseCase get _updateHelpRequestStatusUseCase => Get.find<UpdateHelpRequestStatusUseCase>();

  // InMemoryHelpRepository chỉ dùng cho supporter management (giữ nguyên)
  final repository = Get.put(InMemoryHelpRepository());

  final isLoading = false.obs;

  final RxList<HelpRequest> requests = <HelpRequest>[].obs;

  final RxList<HelpRequest> requestsUserCurrent = <HelpRequest>[].obs;

  final RxList<SupporterModel> supporters = <SupporterModel>[].obs;
  final Rxn<HelpRequest> selectedRequest = Rxn<HelpRequest>();
  final RxList<SupporterModel> selectedSupporters = <SupporterModel>[].obs;

  // Thêm các biến cho tìm kiếm
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final Rx<LatLng> mapCenter = LatLng(16.0, 108.2).obs;
  final RxDouble mapZoom = 8.0.obs;
  final RxBool shouldAnimateToLocation = false.obs;

  // Thêm biến để lưu marker vị trí tìm kiếm
  final Rxn<LatLng> searchLocationMarker = Rxn<LatLng>();

  StreamSubscription? _reqSub; // Generic type để tránh conflict
  StreamSubscription<List<SupporterModel>>? _supSub;

  @override
  void onInit() {
    super.onInit();
    print('HelpController.onInit() called');

    // Stream từ repository (in-memory) cho supporters
    _supSub = repository.streamSupporters().listen(
      (list) {
        print('Supporters stream: ${list.length} supporters');
        supporters.assignAll(list);
      },
      onError: (error) {
        print('Error in supporters stream: $error');
      },
    );

    // Stream help requests từ Use Case
    print('Setting up help requests stream...');
    _reqSub = _getHelpRequestsUseCase().listen(
      (entities) {
        print('Help requests stream: received ${entities.length} requests');
        final models = entities.map((e) => HelpRequestMapper.toModel(e)).toList();
        requests.assignAll(models);
        print('Updated requests list: ${requests.length} items');
      },
      onError: (error) {
        print('Error in help requests stream: $error');
        if (error is Failure) {
          MinhLoaders.errorSnackBar(title: "Lỗi", message: error.message);
        } else {
          MinhLoaders.errorSnackBar(title: "Lỗi", message: error.toString());
        }
      },
      cancelOnError: false, // Không cancel stream khi có lỗi
    );
    print('Help requests stream setup complete');
  }

  @override
  void onClose() {
    _reqSub?.cancel();
    _userReqSub?.cancel();
    _supSub?.cancel();
    super.onClose();
  }

  Future<void> loadRequestHelp() async {
    try {
      // Show load
      isLoading.value = true;

      print("loadRequestHelp");
      // Fetch từ stream (đã setup trong onInit)
      // Nếu cần load lại, có thể trigger stream
      isLoading.value = false;
    } on Failure catch (failure) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
    }
    finally{
      isLoading.value = false;
    }
  }

  StreamSubscription? _userReqSub; // Generic type để tránh conflict

  Future<void> loadRequestHelpForUserCurrent() async {
    try {
      // Show load
      isLoading.value = true;

      final userCurrent = FirebaseAuth.instance.currentUser;
      if (userCurrent == null) {
        throw ValidationFailure('Bạn chưa đăng nhập');
      }

      // Cancel previous subscription if exists
      await _userReqSub?.cancel();

      // Stream từ Use Case
      _userReqSub = _getHelpRequestsByUserUseCase(userCurrent.uid).listen(
        (entities) {
          final models = entities.map((e) => HelpRequestMapper.toModel(e)).toList();
          requestsUserCurrent.assignAll(models);
        },
        onError: (error) {
          if (error is Failure) {
            MinhLoaders.errorSnackBar(title: "Lỗi", message: error.message);
          }
        },
      );

    } on Failure catch (failure) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
    }
    finally{
      isLoading.value = false;
    }
  }

  void selectRequest(HelpRequest r) {
    selectedRequest.value = r;
    selectedSupporters.clear();
    final sorted = supporters.where((s) => s.available).toList()
      ..sort((a, b) {
        final da = _distKm(r.lat, r.lng, a.lat, a.lng);
        final db = _distKm(r.lat, r.lng, b.lat, b.lng);
        return da.compareTo(db);
      });
    selectedSupporters.addAll(sorted.take(2));
  }

  double _distKm(double lat1, double lon1, double lat2, double lon2) {
    final Distance d = Distance();
    return d.as(LengthUnit.Kilometer, LatLng(lat1, lon1), LatLng(lat2, lon2));
  }

  Future<void> assignSelectedSupporters() async {
    try {
      for (var s in selectedSupporters) {
        await repository.reserveSupporter(s.id);
      }
      final req = selectedRequest.value;
      if (req != null) {
        // Update status using Use Case
        // Convert core enum to domain enum
        final domainStatus = domain.RequestStatus.values.firstWhere(
          (s) => s.name == core.RequestStatus.pending.name,
          orElse: () => domain.RequestStatus.pending,
        );
        await _updateHelpRequestStatusUseCase(req.id, domainStatus);
      }
      selectedSupporters.clear();
    } on Failure catch (failure) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'YourAppName/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        searchResults.assignAll(
          data
              .map<Map<String, dynamic>>(
                (item) => {
                  'display_name': item['display_name'],
                  'lat': item['lat'],
                  'lon': item['lon'],
                },
              )
              .toList(),
        );
      } else {
        searchResults.clear();
        MinhLoaders.errorSnackBar(
            title: "Congratulations",
            message: "Your name has been updated"
        );
        // Get.snackbar(
        //   'Lỗi',
        //   'Không thể tìm kiếm địa điểm',
        //   snackPosition: SnackPosition.BOTTOM,
        //   colorText: ,
        // );
      }
    } catch (e) {
      searchResults.clear();
      // Get.snackbar(
      //   'Lỗi',
      //   'Đã xảy ra lỗi khi tìm kiếm: $e',
      //   snackPosition: SnackPosition.BOTTOM,
      // );

      MinhLoaders.errorSnackBar(
          title: "Congratulations",
          message: 'Đã xảy ra lỗi khi tìm kiếm: $e'
      );
    }
  }

  // Di chuyển bản đồ đến vị trí tìm kiếm và thêm marker
  void moveToLocation(LatLng location) {
    mapCenter.value = location;
    mapZoom.value = 12.0;
    shouldAnimateToLocation.value = true;

    // Thêm marker cho vị trí tìm kiếm
    searchLocationMarker.value = location;

    // Xóa kết quả tìm kiếm
    searchResults.clear();
  }

  // Xóa kết quả tìm kiếm
  void clearSearch() {
    searchResults.clear();
    searchLocationMarker.value = null;
  }

  // Xóa marker tìm kiếm
  void clearSearchMarker() {
    searchLocationMarker.value = null;
  }
}


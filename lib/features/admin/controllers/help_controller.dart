import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cuutrobaolu/data/repositories/help/help_repository_inmemory.dart';
import 'package:cuutrobaolu/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/features/shop/models/supporter_modal.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:get/get.dart';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class HelpController extends GetxController {
  static HelpController get to => Get.find();

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

  StreamSubscription<List<HelpRequest>>? _reqSub;
  StreamSubscription<List<SupporterModel>>? _supSub;

  @override
  void onInit() {
    super.onInit();
    _reqSub = repository.streamHelpRequests().listen(
      (list) => requests.assignAll(list),
    );
    _supSub = repository.streamSupporters().listen(
      (list) => supporters.assignAll(list),
    );

    loadRequestHelp();

  }

  @override
  void onClose() {
    _reqSub?.cancel();
    _supSub?.cancel();
    super.onClose();
  }

  Future<void> loadRequestHelp() async {
    try {
      // Show load
      isLoading.value = true;

      print("loadRequestHelp");
      // Fetch banners from data source (Firestore, API, etc,    )
      final helpRequests = await repository.fetchHelpRequest();

      // Update the banners list
      requests.assignAll(helpRequests);


    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Oh Snap !!!!", message: e.toString());
    }
    finally{
      isLoading.value = false;
    }
  }

  Future<void> loadRequestHelpForUserCurrent() async {
    try {
      // Show load
      isLoading.value = true;

      // Fetch banners from data source (Firestore, API, etc,    )
      final helpRequestsCurrent = await repository.fetchHelpRequestForCurrentUser();

      // Update the banners list
      requestsUserCurrent.assignAll(helpRequestsCurrent);


    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Oh Snap !!!!", message: e.toString());
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
    for (var s in selectedSupporters) {
      await repository.reserveSupporter(s.id);
    }
    final req = selectedRequest.value;
    if (req != null)
      await repository.updateHelpStatus(req.id, RequestStatus.pending);
    selectedSupporters.clear();
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

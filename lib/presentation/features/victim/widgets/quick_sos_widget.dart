import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/core/utils/network_manager.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/sos_queue_service.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/domain/usecases/create_help_request_usecase.dart';
import 'package:cuutrobaolu/presentation/features/home/models/help_request_modal.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

/// Quick SOS FAB Button - Collapsible version
class QuickSOSButton extends StatefulWidget {
  const QuickSOSButton({super.key});

  @override
  State<QuickSOSButton> createState() => _QuickSOSButtonState();
}

class _QuickSOSButtonState extends State<QuickSOSButton> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded SOS button - uses AnimatedOpacity for smooth transition
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isExpanded ? 1.0 : 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 48 : 0,
            margin: EdgeInsets.only(bottom: _isExpanded ? 8 : 0),
            child: _isExpanded
                ? FloatingActionButton.extended(
                    heroTag: 'sos_extended',
                    onPressed: () => _showQuickSOSBottomSheet(context),
                    backgroundColor: Colors.red.shade700,
                    elevation: 8,
                    icon: const Icon(Icons.sos, color: Colors.white),
                    label: const Text(
                      'Gửi SOS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        // Main toggle button - small circle
        FloatingActionButton.small(
          heroTag: 'sos_toggle',
          onPressed: _toggleExpanded,
          backgroundColor: _isExpanded ? Colors.grey.shade600 : Colors.red.shade700,
          elevation: 6,
          child: Icon(
            _isExpanded ? Icons.close : Icons.sos,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _showQuickSOSBottomSheet(BuildContext context) {
    setState(() => _isExpanded = false); // Collapse button when opening sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickSOSBottomSheet(),
    );
  }
}


/// Quick SOS Bottom Sheet Widget
class QuickSOSBottomSheet extends StatefulWidget {
  const QuickSOSBottomSheet({super.key});

  @override
  State<QuickSOSBottomSheet> createState() => _QuickSOSBottomSheetState();
}

class _QuickSOSBottomSheetState extends State<QuickSOSBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final _isLoading = false.obs;
  final _currentPosition = Rxn<Position>();
  final _currentAddress = ''.obs;
  LocationService? _locationService;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _getCurrentLocation();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService?.getCurrentLocation();
      _currentPosition.value = position;

      if (position != null) {
        final address = await _locationService?.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        _currentAddress.value = address ?? 'Đang xác định vị trí...';
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _currentAddress.value = 'Không thể xác định vị trí';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sos,
                      color: Colors.red.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gửi SOS Khẩn cấp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yêu cầu hỗ trợ ngay lập tức',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current location
              Obx(() => _LocationCard(
                    address: _currentAddress.value,
                    isLoading: _currentPosition.value == null,
                    onRefresh: _getCurrentLocation,
                  )),
              const SizedBox(height: 16),

              // Quick description (optional)
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Mô tả ngắn gọn tình huống (tùy chọn)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Iconsax.edit),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Quick SOS button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading.value ? null : _sendQuickSOS,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, size: 24),
                      label: Text(
                        _isLoading.value ? 'Đang gửi...' : 'Gửi SOS Ngay',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // Emergency call buttons
              const Text(
                'Hoặc gọi điện khẩn cấp:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EmergencyCallButton(
                      label: 'Cứu hộ 113',
                      phoneNumber: '113',
                      icon: Iconsax.call,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmergencyCallButton(
                      label: 'Y tế 115',
                      phoneNumber: '115',
                      icon: Iconsax.hospital,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmergencyCallButton(
                      label: 'PCCC 114',
                      phoneNumber: '114',
                      icon: Iconsax.danger,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendQuickSOS() async {
    // Check location
    if (_currentPosition.value == null) {
      MinhLoaders.warningSnackBar(
        title: 'Đang lấy vị trí...',
        message: 'Vui lòng đợi trong giây lát',
      );
      await _getCurrentLocation();
      if (_currentPosition.value == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Không thể lấy vị trí hiện tại',
        );
        return;
      }
    }

    _isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final position = _currentPosition.value!;
      final description = _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Yêu cầu hỗ trợ khẩn cấp';
      final address = _currentAddress.value.isNotEmpty
          ? _currentAddress.value
          : 'Vị trí GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      final contact = user.phoneNumber ?? user.email ?? user.uid;

      // Check network
      final connected = await NetworkManager.instance.isConnected();
      if (!connected) {
        // Save offline
        final sosEntry = {
          'title': 'SOS Khẩn cấp',
          'description': description,
          'lat': position.latitude,
          'lng': position.longitude,
          'contact': contact,
          'address': address,
          'userId': user.uid,
          'severity': RequestSeverity.urgent,
          'type': RequestType.rescue,
        };
        await Get.put(SosQueueService()).enqueue(sosEntry);

        _isLoading.value = false;
        Get.back();
        MinhLoaders.successSnackBar(
          title: 'Đã lưu ngoại tuyến',
          message: 'Yêu cầu SOS sẽ được gửi khi có mạng',
        );
        return;
      }

      // Create help request
      final helpRequest = HelpRequest(
        id: '',
        title: 'SOS Khẩn cấp',
        description: description,
        lat: position.latitude,
        lng: position.longitude,
        contact: contact,
        address: address,
        userId: user.uid,
        severity: RequestSeverity.urgent,
        type: RequestType.rescue,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      // Send to backend
      final createHelpRequestUseCase = Get.find<CreateHelpRequestUseCase>();
      final helpRequestEntity = HelpRequestMapper.toEntity(helpRequest);
      await createHelpRequestUseCase(helpRequestEntity);

      _isLoading.value = false;
      Get.back();
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Yêu cầu SOS đã được gửi. Hỗ trợ đang trên đường!',
      );
    } catch (e) {
      _isLoading.value = false;
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể gửi yêu cầu: ${e.toString()}',
      );
    }
  }
}

/// Location card widget
class _LocationCard extends StatelessWidget {
  final String address;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _LocationCard({
    required this.address,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.location,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vị trí hiện tại',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Đang xác định...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      )
                    : Text(
                        address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Cập nhật vị trí',
          ),
        ],
      ),
    );
  }
}

/// Emergency call button widget
class _EmergencyCallButton extends StatelessWidget {
  final String label;
  final String phoneNumber;
  final IconData icon;
  final Color color;

  const _EmergencyCallButton({
    required this.label,
    required this.phoneNumber,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _makeCall(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}


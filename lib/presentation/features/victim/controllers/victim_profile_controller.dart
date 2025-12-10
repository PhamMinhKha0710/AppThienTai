import 'dart:async';
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VictimProfileController extends GetxController {
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final myRequests = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  StreamSubscription? _requestsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadMyRequests();
  }

  @override
  void onClose() {
    _requestsSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadMyRequests() async {
    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;
      print('Loading requests for userId: $userId');
      
      if (userId == null) {
        print('User ID is null, cannot load requests');
        myRequests.value = [];
        isLoading.value = false;
        return;
      }

      // Cancel previous subscription if exists
      await _requestsSubscription?.cancel();

      // Listen to stream
      _requestsSubscription = _helpRequestRepo.getRequestsByUserId(userId).listen(
        (requests) {
          print('Received ${requests.length} requests for user $userId');
          if (requests.isNotEmpty) {
            print('First request: ${requests.first.id} - ${requests.first.title}');
            print('First request createdAt: ${requests.first.createdAt}');
          }
          myRequests.value = requests.map((req) {
            try {
              return _formatRequest(req);
            } catch (e) {
              print('Error formatting request ${req.id}: $e');
              return null;
            }
          }).where((req) => req != null).cast<Map<String, dynamic>>().toList();
          isLoading.value = false;
        },
        onError: (error) {
          print('Error in stream: $error');
          print('Error type: ${error.runtimeType}');
          String errorMessage = 'Không thể tải yêu cầu';
          if (error.toString().contains('index')) {
            errorMessage = 'Đang cập nhật cơ sở dữ liệu. Vui lòng thử lại sau.';
          } else {
            errorMessage = 'Không thể tải yêu cầu: ${error.toString()}';
          }
          Get.snackbar('Lỗi', errorMessage);
          isLoading.value = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error loading my requests: $e');
      print('Error stack: ${StackTrace.current}');
      Get.snackbar('Lỗi', 'Không thể tải yêu cầu: $e');
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _formatRequest(dynamic request) {
    final createdAt = request.createdAt as DateTime?;
    final timeStr = createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
        : '';

    return {
      'id': request.id,
      'title': request.title,
      'description': request.description,
      'status': request.status.name,
      'statusVi': request.status.viName,
      'severity': request.severity.name,
      'severityVi': request.severity.viName,
      'type': request.type.name,
      'typeVi': request.type.viName,
      'address': request.address,
      'lat': request.lat,
      'lng': request.lng,
      'createdAt': createdAt,
      'timeStr': timeStr,
    };
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'inProgress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getSeverityColor(String severity) {
    switch (severity) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/domain/repositories/donation_repository.dart';
import 'package:cuutrobaolu/data/repositories/user/user_repository_adapter.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VolunteerProfileController extends GetxController {
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  final DonationRepository _donationRepo = getIt<DonationRepository>();
  final UserRepositoryAdapter _userRepo = getIt<UserRepositoryAdapter>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  // Skills
  final skills = <String>[].obs;
  final availableSkills = [
    'Y tế',
    'Cứu hộ',
    'Giao thông',
    'Xây dựng',
    'Tâm lý',
    'Dịch vụ',
    'Logistics',
    'IT',
  ];

  // Toggles
  final isAvailable = true.obs;
  final notificationsEnabled = true.obs;
  final locationSharingEnabled = true.obs;

  // Stats
  final completedTasksCount = 0.obs;
  final totalHours = 0.obs;
  final contributionsCount = 0.obs;
  final isLoading = false.obs;

  // History
  final completedTasks = <Map<String, dynamic>>[].obs;
  final contributions = <Map<String, dynamic>>[].obs;

  Future<void> loadProfileData() async {
    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Load skills from user profile
      await _loadSkills(userId);

      // Load completed tasks
      await _loadCompletedTasks(userId);

      // Load contributions (shelters created by volunteer)
      await _loadContributions(userId);

      // Calculate stats
      await _calculateStats(userId);
    } catch (e) {
      print('Error loading profile data: $e');
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu hồ sơ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSkills(String userId) async {
    try {
      final user = await _userRepo.getCurrentUser();
      if (user != null) {
        // Load skills from user document
        // Check Firestore directly for Skills field
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['Skills'] != null) {
            final skillsList = data['Skills'] as List<dynamic>?;
            skills.value = skillsList?.map((s) => s.toString()).toList() ?? [];
          } else {
            skills.value = [];
          }
          
          // Load toggles
          isAvailable.value = data?['IsAvailable'] ?? true;
          notificationsEnabled.value = data?['NotificationsEnabled'] ?? true;
          locationSharingEnabled.value = data?['LocationSharingEnabled'] ?? true;
        }
      }
    } catch (e) {
      print('Error loading skills: $e');
      skills.value = [];
    }
  }

  Future<void> _loadCompletedTasks(String userId) async {
    try {
      // Get all completed requests where VolunteerId matches current user
      // Note: We need to check Firestore directly for VolunteerId field
      final completedSnapshot = await FirebaseFirestore.instance
          .collection('help_requests')
          .where('Status', isEqualTo: 'completed')
          .where('VolunteerId', isEqualTo: userId)
          .get();

      final myCompletedTasks = completedSnapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['CreatedAt'] as Timestamp?;
        return {
          'id': doc.id,
          'title': data['Title'] ?? '',
          'date': createdAt != null
              ? DateFormat('yyyy-MM-dd').format(createdAt.toDate())
              : '',
          'location': data['Address'] ?? '',
          'hours': 0, // Will be calculated from time donations
        };
      }).toList();

      completedTasks.value = myCompletedTasks;
      completedTasksCount.value = myCompletedTasks.length;
    } catch (e) {
      print('Error loading completed tasks: $e');
      // If VolunteerId field doesn't exist, return empty list
      completedTasks.value = [];
      completedTasksCount.value = 0;
    }
  }

  Future<void> _loadContributions(String userId) async {
    try {
      // Get all shelters and filter by CreatedBy
      final allShelters = await _shelterRepo.getAllShelters().first;
      final myShelters = allShelters
          .where((shelter) => shelter.createdBy == userId)
          .toList();

      contributions.value = myShelters.map((shelter) {
        return {
          'id': shelter.id,
          'type': 'Shelter',
          'title': shelter.name,
          'date': DateFormat('yyyy-MM-dd').format(shelter.createdAt),
          'location': shelter.address,
        };
      }).toList();

      contributionsCount.value = myShelters.length;
    } catch (e) {
      print('Error loading contributions: $e');
      contributions.value = [];
    }
  }

  Future<void> _calculateStats(String userId) async {
    try {
      // Get total hours from time donations
      final totalHoursDonated = await _donationRepo.getTotalTimeDonated(userId);
      totalHours.value = totalHoursDonated.toInt();

      // Contributions count already set in _loadContributions
      // Completed tasks count already set in _loadCompletedTasks
    } catch (e) {
      print('Error calculating stats: $e');
    }
  }

  Future<void> toggleSkill(String skill) async {
    if (skills.contains(skill)) {
      skills.remove(skill);
    } else {
      skills.add(skill);
    }
    // Save to Firestore
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _userRepo.updateSingField({
          'Skills': skills.toList(),
        });
      }
    } catch (e) {
      print('Error saving skills: $e');
      Get.snackbar('Lỗi', 'Không thể lưu kỹ năng: $e');
    }
  }

  Future<void> toggleAvailability(bool value) async {
    isAvailable.value = value;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _userRepo.updateSingField({
          'IsAvailable': value,
        });
      }
    } catch (e) {
      print('Error saving availability: $e');
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _userRepo.updateSingField({
          'NotificationsEnabled': value,
        });
      }
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  Future<void> toggleLocationSharing(bool value) async {
    locationSharingEnabled.value = value;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _userRepo.updateSingField({
          'LocationSharingEnabled': value,
        });
      }
    } catch (e) {
      print('Error saving location sharing: $e');
    }
  }

  void addSkill() {
    // TODO: Show dialog to add custom skill
    Get.snackbar('Thông báo', 'Tính năng thêm kỹ năng tùy chỉnh sẽ sớm có mặt');
  }
}



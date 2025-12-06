import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/data/DummyData/MinhDummyData.dart';
import 'package:cuutrobaolu/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/features/shop/models/supporter_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:uuid/uuid.dart';

import '../../../util/constants/enums.dart';


class InMemoryHelpRepository extends GetxController {

  final _db = FirebaseFirestore.instance;

  InMemoryHelpRepository get instance => Get.find();


  final _reqCtrl = StreamController<List<HelpRequest>>.broadcast();
  final _supCtrl = StreamController<List<SupporterModel>>.broadcast();

  final List<HelpRequest> _reqs = [];
  final List<SupporterModel> _sups = [];

  InMemoryHelpRepository() {
    // seed with demo data
    final idGen = Uuid();
    _reqs.addAll(MinhDummyData.helps);
    _sups.addAll(MinhDummyData.supporters);

    // initial push
    Future.microtask(() {
      _reqCtrl.add(List.from(_reqs));
      _supCtrl.add(List.from(_sups));
    });
  }

  Stream<List<HelpRequest>> streamHelpRequests() => _reqCtrl.stream;
  Stream<List<SupporterModel>> streamSupporters() => _supCtrl.stream;

  Future<void> addHelpRequest(HelpRequest r) async {
    _reqs.add(r);
    _reqCtrl.add(List.from(_reqs));
  }

  Future<void> addSupporter(SupporterModel s) async {
    _sups.add(s);
    _supCtrl.add(List.from(_sups));
  }

  // simulate reserve (decrement capacity)
  Future<bool> reserveSupporter(String supporterId) async {
    final idx = _sups.indexWhere((s) => s.id == supporterId);
    if (idx == -1) return false;
    final s = _sups[idx];
    if (!s.available || s.capacity <= 0) return false;
    s.capacity -= 1;
    if (s.capacity <= 0) s.available = false;
    _supCtrl.add(List.from(_sups));
    return true;
  }

  Future<void> updateHelpStatus(String id, RequestStatus newStatus) async {
    final index = _reqs.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _reqs[index] = _reqs[index].copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    _reqCtrl.add(List.from(_reqs));
  }

  Future<List<HelpRequest>> fetchHelpRequest() async {
    try {
      final snapshot = await _db
          .collection("help_requests")
          .get();
      return snapshot.docs.map((doc) => HelpRequest.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Lỗi tải Dữ Liệu");
      throw e.toString();
    }
  }

  Future<List<HelpRequest>> fetchHelpRequestForCurrentUser() async {
    try {

      final userCurrent = FirebaseAuth.instance.currentUser;

      if(userCurrent == null)
      {
        print("Bạn Chưa Đăng Nhập");
        throw "Bạn Chưa Đăng Nhập";
      }

      final snapshot = await _db
          .collection("help_requests")
          .where("UserId", isEqualTo: userCurrent.uid)
          .get();
      return snapshot.docs.map((doc) => HelpRequest.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Lỗi tải Dữ Liệu");
      throw e.toString();
    }
  }

}

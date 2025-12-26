import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/data/models/shelter_dto.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:get/get.dart';

class SheltersRepository extends GetxController
{
  static SheltersRepository get instance => Get.find();


  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // lấy vị trí gần nhất
  Future<List<ShelterDto>> getNearestShelters() async {
    try {
      final snapshot = await _db.collection("Shelters").get();
      final shelters = snapshot.docs.map((doc) => ShelterDto.fromSnapshot(doc)).toList();
      return shelters;
    }
    catch (e) {
      print('Error getting shelters: $e');
      return [];
    }
  }

}
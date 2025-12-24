import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:get/get.dart';

class VictimSheltersNearest extends GetxController
{
  static VictimSheltersNearest get instance => Get.find();


 final RxList<ShelterEntity> _shelters = <ShelterEntity>[].obs;





}
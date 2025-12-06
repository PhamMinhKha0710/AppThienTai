import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings
{

  @override
  void dependencies() {
    Get.put(NetworkManager());
  }
}
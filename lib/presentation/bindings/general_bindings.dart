import 'package:get/get.dart';
import '../../core/utils/network_manager.dart';

class GeneralBindings extends Bindings
{

  @override
  void dependencies() {
    Get.put(NetworkManager());
  }
}

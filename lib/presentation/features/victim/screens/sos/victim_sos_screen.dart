import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_sos_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class VictimSosScreen extends StatelessWidget {
  const VictimSosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimSosController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Gửi yêu cầu SOS"),
        showBackArrow: true,
      ),
      body: _SosStepper(controller: controller),
      floatingActionButton: Obx(() {
        if (controller.currentStep.value == 2 && !controller.isSubmitting.value) {
          return FloatingActionButton.extended(
            onPressed: () => controller.submitSOS(),
            backgroundColor: Colors.red,
            icon: Icon(Iconsax.send_1),
            label: Text("Gửi SOS"),
          );
        }
        return SizedBox.shrink();
      }),
    );
  }
}

class _SosStepper extends StatelessWidget {
  final VictimSosController controller;

  const _SosStepper({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stepper(
      currentStep: controller.currentStep.value,
      onStepContinue: controller.nextStep,
      onStepCancel: controller.previousStep,
      steps: [
        // Bước 1: Mô tả
        Step(
          title: Text("Mô tả vấn đề"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Mô tả chi tiết tình huống khẩn cấp...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(() {
                final position = controller.currentPosition.value;
                if (position == null) {
                  return Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: MinhSizes.spaceBtwItems),
                      Text("Đang lấy vị trí..."),
                    ],
                  );
                }
                return Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(MinhSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.location, color: Colors.blue),
                            SizedBox(width: MinhSizes.spaceBtwItems / 2),
                            Text(
                              "Tọa độ hiện tại:",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems / 2),
                        Text(
                          "Lat: ${position.latitude.toStringAsFixed(6)}\nLng: ${position.longitude.toStringAsFixed(6)}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          isActive: controller.currentStep.value >= 0,
          state: controller.currentStep.value > 0
              ? StepState.complete
              : StepState.indexed,
        ),

        // Bước 2: Attach media
        Step(
          title: Text("Đính kèm hình ảnh/video"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chụp ảnh hoặc quay video để mô tả tình huống",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.pickImage(ImageSource.camera),
                      icon: Icon(Iconsax.camera),
                      label: Text("Chụp ảnh"),
                    ),
                  ),
                  SizedBox(width: MinhSizes.spaceBtwItems),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.pickImage(ImageSource.gallery),
                      icon: Icon(Iconsax.gallery),
                      label: Text("Chọn từ thư viện"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(() {
                if (controller.selectedImages.isEmpty) {
                  return SizedBox.shrink();
                }
                return Wrap(
                  spacing: MinhSizes.spaceBtwItems,
                  runSpacing: MinhSizes.spaceBtwItems,
                  children: controller.selectedImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => controller.removeImage(image),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }),
            ],
          ),
          isActive: controller.currentStep.value >= 1,
          state: controller.currentStep.value > 1
              ? StepState.complete
              : StepState.indexed,
        ),

        // Bước 3: Xác nhận và gửi
        Step(
          title: Text("Xác nhận và gửi"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vui lòng xem lại thông tin trước khi gửi:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(MinhSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mô tả:",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems / 2),
                      Text(controller.descriptionController.text),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      Text(
                        "Hình ảnh: ${controller.selectedImages.length}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(() {
                if (controller.isSubmitting.value) {
                  return Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: MinhSizes.spaceBtwItems),
                        Text("Đang gửi yêu cầu..."),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
          isActive: controller.currentStep.value >= 2,
          state: StepState.indexed,
        ),
      ],
    ));
  }
}

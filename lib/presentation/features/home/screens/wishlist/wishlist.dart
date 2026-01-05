import 'package:cuutrobaolu/presentation/features/home/controllers/wishlist_province_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WishlistProvinceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vietnam Provinces Picker'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() => Center(
              child: Text(
                controller.currentVersion.value == AdministrativeDivisionVersion.v1
                    ? '3-Level (v1)'
                    : '2-Level (v2)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Administrative Division Version',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Obx(() {
                        return SegmentedButton<AdministrativeDivisionVersion>(
                          segments: const [
                            ButtonSegment<AdministrativeDivisionVersion>(
                              value: AdministrativeDivisionVersion.v1,
                              label: Text('v1 (3-Level)'),
                              icon: Icon(Icons.account_tree),
                            ),
                            ButtonSegment<AdministrativeDivisionVersion>(
                              value: AdministrativeDivisionVersion.v2,
                              label: Text('v2 (2-Level)'),
                              icon: Icon(Icons.layers),
                            ),
                          ],
                          selected: {controller.currentVersion.value},
                          onSelectionChanged: (Set<AdministrativeDivisionVersion> newSelection) {
                            controller.switchVersion(newSelection.first);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      controller.currentVersion.value == AdministrativeDivisionVersion.v1
                          ? 'Province > District > Ward (Before July 2025)'
                          : 'Province > Ward (From July 2025)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Province Selector
            Obx(() => _buildDropdownSection(
              title: "Select Province",
              hintText: "Search for a province",
              items: controller.filteredProvinces.map((p) => p.name).toList(),
              onSearchChanged: controller.updateFilteredProvinces,
              currentValueSelected: controller.selectedProvince.value?.name,
              onItemSelected: controller.selectProvince,
            )),

            // District Selector (only for v1)
            Obx(() {
              if (controller.selectedProvince.value != null &&
                  controller.currentVersion.value == AdministrativeDivisionVersion.v1) {
                return _buildDropdownSection(
                  title: "Select District",
                  hintText: "Search for a district",
                  items: controller.filteredDistricts.map((d) => d.name).toList(),
                  onSearchChanged: controller.updateFilteredDistricts,
                  currentValueSelected: controller.selectedDistrict.value?.name,
                  onItemSelected: controller.selectDistrict,
                );
              }
              return const SizedBox.shrink();
            }),

            // Ward Selector
            Obx(() {
              final showWard = (controller.currentVersion.value == AdministrativeDivisionVersion.v2 &&
                      controller.selectedProvince.value != null) ||
                  (controller.currentVersion.value == AdministrativeDivisionVersion.v1 &&
                      controller.selectedDistrict.value != null);
              
              if (showWard) {
                return _buildDropdownSection(
                  title: "Select Ward",
                  hintText: "Search for a ward",
                  items: controller.filteredWards.map((w) => w.name).toList(),
                  onSearchChanged: controller.updateFilteredWards,
                  currentValueSelected: controller.selectedWard.value?.name,
                  onItemSelected: controller.selectWard,
                );
              }
              return const SizedBox.shrink();
            }),

            // Selection Result
            Obx(() {
              if (controller.selectedWard.value != null) {
                return Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Address:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.currentVersion.value == AdministrativeDivisionVersion.v1
                                ? "${controller.selectedWard.value?.name} - ${controller.selectedDistrict.value?.name} - ${controller.selectedProvince.value?.name}"
                                : "${controller.selectedWard.value?.name} - ${controller.selectedProvince.value?.name}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      )),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String hintText,
    required List<String> items,
    required void Function(String query) onSearchChanged,
    required void Function(String selectedItem) onItemSelected,
    required String? currentValueSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentValueSelected,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value != null) onItemSelected(value);
            },
          ),
        ],
      ),
    );
  }
}

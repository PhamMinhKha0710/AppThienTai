import 'package:cuutrobaolu/core/utils/vietnam_provinces_helper.dart';

import 'package:flutter/material.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

// class FavoriteScreen extends StatelessWidget {
//   const FavoriteScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return Scaffold(
//       appBar: MinhAppbar(
//         title: Text("WishList"),
//         action: [
//           MinhCircularIcon(
//             icon: Iconsax.add,
//             onPressed: () {
//
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(MinhSizes.defaultSpace),
//           child: Text("wishlist"),
//         ),
//       ),
//     );
//   }
// }

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _HomePageState();
}

class _HomePageState extends State<FavoriteScreen> {
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  List<Province> filteredProvinces = [];
  List<District> filteredDistricts = [];
  List<Ward> filteredWards = [];

  AdministrativeDivisionVersion currentVersion =
      AdministrativeDivisionVersion.v2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProvinces();
  }

  Future<void> _initializeProvinces() async {
    try {
      await VietnamProvincesHelper.ensureInitialized(version: currentVersion);
      final provinces = await VietnamProvincesHelper.getProvinces(version: currentVersion);
      setState(() {
        filteredProvinces = provinces;
      });
    } catch (e) {
      print('Error initializing provinces: $e');
    }
  }

  Future<void> switchVersion(AdministrativeDivisionVersion newVersion) async {
    if (newVersion == currentVersion) return;

    setState(() {
      isLoading = true;
      selectedProvince = null;
      selectedDistrict = null;
      selectedWard = null;
      filteredDistricts = [];
      filteredWards = [];
    });

    try {
      await VietnamProvincesHelper.ensureInitialized(version: newVersion);
      final provinces = await VietnamProvincesHelper.getProvinces(version: newVersion);
      setState(() {
        currentVersion = newVersion;
        filteredProvinces = provinces;
        isLoading = false;
      });
    } catch (e) {
      print('Error switching version: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateFilteredProvinces(String query) async {
    selectedProvince = null;
    selectedDistrict = null;
    selectedWard = null;
    filteredWards = [];
    filteredDistricts = [];
    try {
      final provinces = await VietnamProvincesHelper.getProvinces(
        query: query.isEmpty ? null : query,
        version: currentVersion,
      );
      setState(() {
        filteredProvinces = provinces;
      });
    } catch (e) {
      print('Error filtering provinces: $e');
    }
  }

  Future<void> updateFilteredDistricts(String query) async {
    selectedDistrict = null;
    selectedWard = null;
    filteredWards = [];
    if (selectedProvince != null) {
      try {
        final districts = await VietnamProvincesHelper.getDistricts(
          provinceCode: selectedProvince!.code.toString(),
          query: query.isEmpty ? null : query,
          version: currentVersion,
        );
        setState(() {
          filteredDistricts = districts;
        });
      } catch (e) {
        print('Error filtering districts: $e');
      }
    }
  }

  Future<void> updateFilteredWards(String query) async {
    selectedWard = null;
    try {
      if (currentVersion == AdministrativeDivisionVersion.v2) {
        // For v2, wards are directly under province
        if (selectedProvince != null) {
          final wards = await VietnamProvincesHelper.getWards(
            districtCode: '0',
            provinceCode: selectedProvince!.code.toString(),
            query: query.isEmpty ? null : query,
            version: currentVersion,
          );
          setState(() {
            filteredWards = wards;
          });
        }
      } else {
        // For v1, wards are under district
        if (selectedDistrict != null && selectedProvince != null) {
          final wards = await VietnamProvincesHelper.getWards(
            districtCode: selectedDistrict!.code.toString(),
            provinceCode: selectedProvince!.code.toString(),
            query: query.isEmpty ? null : query,
            version: currentVersion,
          );
          setState(() {
            filteredWards = wards;
          });
        }
      }
    } catch (e) {
      print('Error filtering wards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vietnam Provinces Picker'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                currentVersion == AdministrativeDivisionVersion.v1
                    ? '3-Level (v1)'
                    : '2-Level (v2)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
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
                      child:
                      SegmentedButton<AdministrativeDivisionVersion>(
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
                        selected: {currentVersion},
                        onSelectionChanged:
                            (Set<AdministrativeDivisionVersion>
                        newSelection) {
                          switchVersion(newSelection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentVersion == AdministrativeDivisionVersion.v1
                          ? 'Province > District > Ward (Before July 2025)'
                          : 'Province > Ward (From July 2025)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Province Selector
            buildDropdownSection(
              title: "Select Province",
              hintText: "Search for a province",
              items: filteredProvinces.map((p) => p.name).toList(),
              onSearchChanged: updateFilteredProvinces,
              currentValueSelected: selectedProvince?.name,
              onItemSelected: (value) async {
                setState(() {
                  selectedProvince = filteredProvinces
                      .firstWhere((p) => p.name == value);
                  selectedDistrict = null;
                  selectedWard = null;
                });

                try {
                  if (currentVersion ==
                      AdministrativeDivisionVersion.v1) {
                    // For v1, load districts
                    final districts = await VietnamProvincesHelper.getDistricts(
                      provinceCode: selectedProvince!.code.toString(),
                      version: currentVersion,
                    );
                    setState(() {
                      filteredDistricts = districts;
                      filteredWards = [];
                    });
                  } else {
                    // For v2, load wards directly
                    final wards = await VietnamProvincesHelper.getWards(
                      districtCode: '0',
                      provinceCode: selectedProvince!.code.toString(),
                      version: currentVersion,
                    );
                    setState(() {
                      filteredDistricts = [];
                      filteredWards = wards;
                    });
                  }
                } catch (e) {
                  print('Error loading districts/wards: $e');
                }
              },
            ),

            // District Selector (only for v1)
            if (selectedProvince != null &&
                currentVersion == AdministrativeDivisionVersion.v1)
              buildDropdownSection(
                title: "Select District",
                hintText: "Search for a district",
                items: filteredDistricts.map((d) => d.name).toList(),
                onSearchChanged: updateFilteredDistricts,
                currentValueSelected: selectedDistrict?.name,
                onItemSelected: (value) async {
                  setState(() {
                    selectedDistrict = filteredDistricts
                        .firstWhere((d) => d.name == value);
                    selectedWard = null;
                  });
                  try {
                    final wards = await VietnamProvincesHelper.getWards(
                      districtCode: selectedDistrict!.code.toString(),
                      provinceCode: selectedProvince!.code.toString(),
                      version: currentVersion,
                    );
                    setState(() {
                      filteredWards = wards;
                    });
                  } catch (e) {
                    print('Error loading wards: $e');
                  }
                },
              ),

            // Ward Selector
            if ((currentVersion == AdministrativeDivisionVersion.v2 &&
                selectedProvince != null) ||
                (currentVersion == AdministrativeDivisionVersion.v1 &&
                    selectedDistrict != null))
              buildDropdownSection(
                title: "Select Ward",
                hintText: "Search for a ward",
                items: filteredWards.map((w) => w.name).toList(),
                onSearchChanged: updateFilteredWards,
                currentValueSelected: selectedWard?.name,
                onItemSelected: (value) {
                  setState(() {
                    selectedWard =
                        filteredWards.firstWhere((w) => w.name == value);
                  });
                },
              ),

            // Selection Result
            if (selectedWard != null)
              Card(
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
                          currentVersion ==
                              AdministrativeDivisionVersion.v1
                              ? "${selectedWard?.name} - ${selectedDistrict?.name} - ${selectedProvince?.name}"
                              : "${selectedWard?.name} - ${selectedProvince?.name}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownSection({
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

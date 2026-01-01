import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Supply Category Enum - Danh mục vật phẩm quyên góp
enum SupplyCategory {
  food,
  water,
  clothing,
  medicine,
  hygiene,
  shelter,
  tools,
  other;

  /// Tên tiếng Việt của danh mục
  String get viName {
    switch (this) {
      case SupplyCategory.food:
        return 'Thực phẩm';
      case SupplyCategory.water:
        return 'Nước uống';
      case SupplyCategory.clothing:
        return 'Quần áo';
      case SupplyCategory.medicine:
        return 'Thuốc men/Y tế';
      case SupplyCategory.hygiene:
        return 'Đồ dùng vệ sinh';
      case SupplyCategory.shelter:
        return 'Lều trú ẩn/Chăn màn';
      case SupplyCategory.tools:
        return 'Công cụ/Dụng cụ';
      case SupplyCategory.other:
        return 'Khác';
    }
  }

  /// Icon cho danh mục
  IconData get icon {
    switch (this) {
      case SupplyCategory.food:
        return Iconsax.cake;
      case SupplyCategory.water:
        return Iconsax.drop;
      case SupplyCategory.clothing:
        return Iconsax.tag;
      case SupplyCategory.medicine:
        return Iconsax.health;
      case SupplyCategory.hygiene:
        return Iconsax.bucket;
      case SupplyCategory.shelter:
        return Iconsax.home;
      case SupplyCategory.tools:
        return Iconsax.setting;
      case SupplyCategory.other:
        return Iconsax.box;
    }
  }

  /// Màu sắc cho danh mục
  Color get color {
    switch (this) {
      case SupplyCategory.food:
        return Colors.orange;
      case SupplyCategory.water:
        return Colors.blue;
      case SupplyCategory.clothing:
        return Colors.purple;
      case SupplyCategory.medicine:
        return Colors.red;
      case SupplyCategory.hygiene:
        return Colors.teal;
      case SupplyCategory.shelter:
        return Colors.brown;
      case SupplyCategory.tools:
        return Colors.grey;
      case SupplyCategory.other:
        return Colors.grey.shade600;
    }
  }

  /// Parse từ string
  static SupplyCategory? fromString(String? value) {
    if (value == null) return null;
    try {
      return SupplyCategory.values.firstWhere(
        (category) => category.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}


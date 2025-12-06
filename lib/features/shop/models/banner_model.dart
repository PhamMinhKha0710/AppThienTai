import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel
{
  String imageUrl, targetScreen, name;
  bool active;


  BannerModel({
    required this.imageUrl,
    required this.active,
    required this.targetScreen,
    required this.name
  });

  static BannerModel empty() {
    return BannerModel( imageUrl: "", active: false, targetScreen: "", name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      "ImageUrl": imageUrl,
      "Active": active,
      "TargetScreen": targetScreen,
      "Name" : name
    };
  }

  factory BannerModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();
    if (data != null) {
      return BannerModel(
        name: data['Name'] ?? "",
        imageUrl: data['ImageUrl'] ?? "",
        active: data['Active'] ?? false,
        targetScreen: data['TargetScreen'] ?? "",
      );
    } else {
      return BannerModel.empty();
    }
  }
}
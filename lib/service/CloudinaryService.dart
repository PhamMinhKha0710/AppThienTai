import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter/services.dart' hide Uint8List;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:http_parser/http_parser.dart';


class CloudinaryService
{
  static const String cloudName = "dh7qxjnde";   // ví dụ: minhapp123
  static const String uploadPreset = "profileUsers";          // preset bạn đã tạo (Unsigned)

  static Future<String?> uploadImage(XFile image, { String folder = "users"}) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/images/upload");

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] =   uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('images', 'jpeg'),
        ));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['secure_url']; // Link ảnh https
      } else {
        print("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  static Future<String?> uploadImageInAsset(XFile image, {String preset = "", String folder = "users"}) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/images/upload");

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = preset.isEmpty ? uploadPreset : preset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('images', 'jpeg'),
        ));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['secure_url']; // Link ảnh https
      } else {
        print("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  /// Upload ảnh trong assets (ví dụ dummy data)
  static Future<String?> uploadAssetImage(String assetPath, {String preset = "",String folder = "users"}) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/images/upload");

      // Đọc file từ assets
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = preset.isEmpty ? uploadPreset : preset
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: assetPath.split("/").last,
          contentType: MediaType('images', 'png'),
        ));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['secure_url'];
      } else {
        print("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }




}
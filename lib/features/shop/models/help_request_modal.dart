import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';

class HelpRequest {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String contact;
  final RequestSeverity severity;
  final RequestStatus status;
  final RequestType type;
  final String address;
  final String? imageUrl;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? province;
  final String? district;
  final String? ward;
  final String? detailedAddress;

  HelpRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.contact,
    required this.address,
    this.imageUrl,
    this.userId,
    this.updatedAt,
    this.severity = RequestSeverity.medium,
    this.status = RequestStatus.pending,
    this.type = RequestType.other,
    DateTime? createdAt,

    this.province,
    this.district,
    this.ward,
    this.detailedAddress,
  }) : createdAt = createdAt ?? DateTime.now();

  static HelpRequest empty() {
    return HelpRequest(
      id: "",
      title: "",
      description: "",
      lat: 0,
      lng: 0,
      contact: "",
      address: "",
      severity: RequestSeverity.medium,
      status: RequestStatus.pending,
      type: RequestType.other,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'Title': title,
      'Description': description,
      'Lat': lat,
      'Lng': lng,
      'Contact': contact,
      'Severity': severity.toJson(),
      'Status': status.toJson(),
      'Type': type.toJson(),
      'Address': address,
      'UserId': userId,
      'ImageUrl': imageUrl,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,

      'Province': province,
      'District': district,
      'Ward': ward,
      'DetailedAddress': detailedAddress,
    };

    if (includeId) map['Id'] = id;

    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    DateTime parseDT(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return HelpRequest(
      id: json['Id'] ?? "",
      title: json['Title'] ?? "",
      description: json['Description'] ?? "",
      lat: (json['Lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['Lng'] as num?)?.toDouble() ?? 0.0,
      contact: json['Contact'] ?? "",
      severity: RequestSeverity.fromString(json['Severity'] ?? 'medium'),
      status: RequestStatus.fromString(json['Status'] ?? 'pending'),
      type: RequestType.fromString(json['Type'] ?? 'other'),
      address: json['Address'] ?? "",
      userId: json['UserId'],
      imageUrl: json['ImageUrl'],
      createdAt: parseDT(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null ? parseDT(json['UpdatedAt']) : null,

      province: json['Province'],
      district: json['District'],
      ward: json['Ward'],
      detailedAddress: json['DetailedAddress'],
    );
  }

  factory HelpRequest.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return HelpRequest.empty();

    return HelpRequest.fromJson({
      ...data,
      'Id': doc.id,
    });
  }

  factory HelpRequest.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return HelpRequest.fromJson({
      ...doc.data(),
      'Id': doc.id,
    });
  }

  HelpRequest copyWith({
    String? id,
    String? title,
    String? description,
    double? lat,
    double? lng,
    String? contact,
    RequestSeverity? severity,
    RequestStatus? status,
    RequestType? type,
    String? address,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,

    String? province,
    String? district,
    String? ward,
    String? detailedAddress,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      contact: contact ?? this.contact,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      type: type ?? this.type,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      detailedAddress: detailedAddress ?? this.detailedAddress,
    );
  }
}

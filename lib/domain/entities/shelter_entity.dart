/// Shelter Entity - Pure business object
class ShelterEntity {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? description;
  final int capacity;
  final int currentOccupancy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? contactPhone;
  final String? contactEmail;
  final List<String>? amenities; // e.g., ["water", "food", "medical"]
  final String? distributionTime; // e.g., "08:00-17:00"

  const ShelterEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.description,
    required this.capacity,
    required this.currentOccupancy,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.contactPhone,
    this.contactEmail,
    this.amenities,
    this.distributionTime,
  });

  int get availableSlots => capacity - currentOccupancy;
  bool get isFull => currentOccupancy >= capacity;

  ShelterEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? description,
    int? capacity,
    int? currentOccupancy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? contactPhone,
    String? contactEmail,
    List<String>? amenities,
    String? distributionTime,
  }) {
    return ShelterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      amenities: amenities ?? this.amenities,
      distributionTime: distributionTime ?? this.distributionTime,
    );
  }
}



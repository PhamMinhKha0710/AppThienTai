/// NotificationSettingsEntity - Settings for notification preferences
class NotificationSettingsEntity {
  final bool enableCriticalSound;
  final bool enableVibration;
  final bool enableGeofencing;
  final double geofenceRadius; // km
  final List<String> subscribedProvinces;
  final List<String> subscribedDistricts;
  final bool enableSosAlerts; // For volunteers
  final bool enableWeatherAlerts;
  final bool enableEvacuationAlerts;
  final bool enableResourceAlerts;

  const NotificationSettingsEntity({
    this.enableCriticalSound = true,
    this.enableVibration = true,
    this.enableGeofencing = true,
    this.geofenceRadius = 10.0,
    this.subscribedProvinces = const [],
    this.subscribedDistricts = const [],
    this.enableSosAlerts = true,
    this.enableWeatherAlerts = true,
    this.enableEvacuationAlerts = true,
    this.enableResourceAlerts = true,
  });

  NotificationSettingsEntity copyWith({
    bool? enableCriticalSound,
    bool? enableVibration,
    bool? enableGeofencing,
    double? geofenceRadius,
    List<String>? subscribedProvinces,
    List<String>? subscribedDistricts,
    bool? enableSosAlerts,
    bool? enableWeatherAlerts,
    bool? enableEvacuationAlerts,
    bool? enableResourceAlerts,
  }) {
    return NotificationSettingsEntity(
      enableCriticalSound: enableCriticalSound ?? this.enableCriticalSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableGeofencing: enableGeofencing ?? this.enableGeofencing,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      subscribedProvinces: subscribedProvinces ?? this.subscribedProvinces,
      subscribedDistricts: subscribedDistricts ?? this.subscribedDistricts,
      enableSosAlerts: enableSosAlerts ?? this.enableSosAlerts,
      enableWeatherAlerts: enableWeatherAlerts ?? this.enableWeatherAlerts,
      enableEvacuationAlerts: enableEvacuationAlerts ?? this.enableEvacuationAlerts,
      enableResourceAlerts: enableResourceAlerts ?? this.enableResourceAlerts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableCriticalSound': enableCriticalSound,
      'enableVibration': enableVibration,
      'enableGeofencing': enableGeofencing,
      'geofenceRadius': geofenceRadius,
      'subscribedProvinces': subscribedProvinces,
      'subscribedDistricts': subscribedDistricts,
      'enableSosAlerts': enableSosAlerts,
      'enableWeatherAlerts': enableWeatherAlerts,
      'enableEvacuationAlerts': enableEvacuationAlerts,
      'enableResourceAlerts': enableResourceAlerts,
    };
  }

  factory NotificationSettingsEntity.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsEntity(
      enableCriticalSound: json['enableCriticalSound'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      enableGeofencing: json['enableGeofencing'] ?? true,
      geofenceRadius: (json['geofenceRadius'] ?? 10.0).toDouble(),
      subscribedProvinces: List<String>.from(json['subscribedProvinces'] ?? []),
      subscribedDistricts: List<String>.from(json['subscribedDistricts'] ?? []),
      enableSosAlerts: json['enableSosAlerts'] ?? true,
      enableWeatherAlerts: json['enableWeatherAlerts'] ?? true,
      enableEvacuationAlerts: json['enableEvacuationAlerts'] ?? true,
      enableResourceAlerts: json['enableResourceAlerts'] ?? true,
    );
  }

  /// Default settings for new users
  factory NotificationSettingsEntity.defaults() {
    return const NotificationSettingsEntity();
  }
}







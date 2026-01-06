  /// Load hazard prediction for current location with real-time weather
  Future<void> loadCurrentLocationPrediction() async {
    final pos = currentPosition.value;
    if (pos == null) {
      debugPrint('[MAP] No current position for prediction');
      return;
    }

    isLoadingPrediction.value = true;
    try {
      final prediction = await _aiService.predictHazardRisk(
        lat: pos.latitude,
        lng: pos.longitude,
        hazardType: 'flood', // Default to flood, can make configurable
        includeWeather: true,
      );

      currentHazardPrediction.value = prediction;
      debugPrint('[MAP] ✓ Loaded prediction with weather for current location');
    } catch (e) {
      debugPrint('[MAP] ✗ Error loading prediction: $e');
    } finally {
      isLoadingPrediction.value = false;
    }
  }

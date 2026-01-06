import 'package:flutter/material.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';

/// Widget to display current weather and forecast data
/// Used in hazard prediction screens to show weather context
class WeatherContextCard extends StatelessWidget {
  final WeatherData? currentWeather;
  final ForecastData? forecast;
  final String hazardType;
  final bool isLoading;
  final bool isForecast; // NEW: Flag to indicate if this is a forecast
  final VoidCallback? onRefresh;
  final VoidCallback? onDismiss;
  final Function(String)? onHazardTypeChanged;

  const WeatherContextCard({
    super.key,
    this.currentWeather,
    this.forecast,
    required this.hazardType,
    this.isLoading = false,
    this.isForecast = false, // Default to false
    this.onRefresh,
    this.onDismiss,
    this.onHazardTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading skeleton
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (currentWeather == null && forecast == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with controls
            _buildHeader(context),
            const SizedBox(height: 12),

            // Current Weather or AI Forecast
            if (currentWeather != null) ...[
              if (isForecast)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        'Dự báo bởi AI cho ngày mai',
                        style: TextStyle(
                          color: Colors.blue.shade700, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildCurrentWeather(context),
              if (forecast != null) const Divider(height: 24),
            ],

            // Forecast
            if (forecast != null) _buildForecast(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(BuildContext context) {
    final weather = currentWeather!;
    
    return Column(
      children: [
        // Temperature and Rain
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (weather.temperature != null)
              _buildWeatherItem(
                icon: Icons.thermostat,
                label: 'Nhiệt độ',
                value: '${weather.temperature!.toStringAsFixed(1)}°C',
                color: _getTemperatureColor(weather.temperature!),
              ),
            if (weather.precipitation != null)
              _buildWeatherItem(
                icon: Icons.water_drop,
                label: 'Mưa hiện tại',
                value: '${weather.precipitation!.toStringAsFixed(1)} mm',
                color: _getRainColor(weather.precipitation!),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Wind and Humidity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (weather.windSpeed != null)
              _buildWeatherItem(
                icon: Icons.air,
                label: 'Gió',
                value: '${weather.windSpeed!.toStringAsFixed(0)} km/h',
                color: _getWindColor(weather.windSpeed!),
              ),
            if (weather.humidity != null)
              _buildWeatherItem(
                icon: Icons.water,
                label: 'Độ ẩm',
                value: '${weather.humidity!.toStringAsFixed(0)}%',
                color: Colors.blue,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context) {
    final fc = forecast!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Dự Báo ${fc.days} Ngày Tới',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Forecast metrics
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildForecastItem(
              icon: Icons.umbrella,
              label: 'Tổng mưa',
              value: '${fc.totalPrecipitation.toStringAsFixed(0)} mm',
              color: _getRainColor(fc.totalPrecipitation),
            ),
            _buildForecastItem(
              icon: Icons.wind_power,
              label: 'Gió max',
              value: '${fc.maxWind.toStringAsFixed(0)} km/h',
              color: _getWindColor(fc.maxWind),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Temperature range
        _buildTemperatureRange(fc.minTemperature, fc.maxTemperature),

        // Weather-based warning
        if (_shouldShowWarning()) ...[
          const SizedBox(height: 12),
          _buildWeatherWarning(context),
        ],
      ],
    );
  }

  Widget _buildWeatherItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureRange(double min, double max) {
    return Row(
      children: [
        const Icon(Icons.thermostat, size: 20, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhiệt độ',  style: TextStyle(fontSize: 11, color: Colors.grey)),
              Row(
                children: [
                  Text(
                    '${min.toStringAsFixed(1)}°C',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const Text(' - '),
                  Text(
                    '${max.toStringAsFixed(1)}°C',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherWarning(BuildContext context) {
    String warning = '';
    Color bgColor = Colors.orange.shade50;
    Color iconColor = Colors.orange;

    if (hazardType == 'flood' || hazardType == 'landslide') {
      if (forecast!.totalPrecipitation > 200) {
        warning = '⚠️ Cảnh báo: Mưa rất lớn trong 7 ngày tới!';
        bgColor = Colors.red.shade50;
        iconColor = Colors.red;
      } else if (forecast!.totalPrecipitation > 100) {
        warning = 'Lưu ý: Dự báo mưa nhiều trong tuần tới';
      }
    } else if (hazardType == 'storm') {
      if (forecast!.maxWind > 60) {
        warning = '⚠️ Cảnh báo: Dự báo gió mạnh!';
        bgColor = Colors.red.shade50;
        iconColor = Colors.red;
      } else if (forecast!.maxWind > 40) {
        warning = 'Lưu ý: Gió có thể mạnh trong tuần tới';
      }
    }

    if (warning.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowWarning() {
    if (forecast == null) return false;

    if (hazardType == 'flood' || hazardType == 'landslide') {
      return forecast!.totalPrecipitation > 100;
    } else if (hazardType == 'storm') {
      return forecast!.maxWind > 40;
    }
    return false;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cloud, color: Colors.blue, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isForecast ? 'Dự Báo Thời Tiết (AI)' : 'Thời Tiết Hiện Tại',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isForecast ? Colors.blue.shade800 : null,
                ),
              ),
              // Hazard type selector
              if (onHazardTypeChanged != null)
                _buildHazardTypeSelector(),
            ],
          ),
        ),
        // Refresh button
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: onRefresh,
            tooltip: 'Làm mới',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        const SizedBox(width: 8),
        // Dismiss button
        if (onDismiss != null)
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDismiss,
            tooltip: 'Đóng',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildHazardTypeSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _buildHazardChip('flood', '🌊 Lũ lụt'),
          const SizedBox(width: 4),
          _buildHazardChip('landslide', '⛰️ Sạt lở'),
          const SizedBox(width: 4),
          _buildHazardChip('storm', '🌀 Bão'),
        ],
      ),
    );
  }

  Widget _buildHazardChip(String type, String label) {
    final isSelected = hazardType == type;
    return GestureDetector(
      onTap: () => onHazardTypeChanged?.call(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weather items skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkeletonItem(),
                _buildSkeletonItem(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkeletonItem(),
                _buildSkeletonItem(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 35) return Colors.red;
    if (temp > 30) return Colors.orange;
    if (temp < 15) return Colors.blue;
    return Colors.green;
  }

  Color _getRainColor(double rain) {
    if (rain > 50) return Colors.red;
    if (rain > 20) return Colors.orange;
    if (rain > 5) return Colors.blue;
    return Colors.grey;
  }

  Color _getWindColor(double wind) {
    if (wind > 60) return Colors.red;
    if (wind > 40) return Colors.orange;
    if (wind > 20) return Colors.blue;
    return Colors.green;
  }
}

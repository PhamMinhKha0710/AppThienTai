import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/widgets/alert_detail_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertEntity alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = AlertSeverityHelper.getColor(alert.severity);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AlertDetailAppBar(
            alert: alert,
            severityColor: severityColor,
            onShare: _shareAlert,
            onReport: () => _reportAlert(context),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(alert: alert, severityColor: severityColor),
                _ContentSection(alert: alert, onShare: _shareAlert),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareAlert() {
    final shareText = '''
🚨 ${alert.title}

${alert.content}

📍 ${alert.location ?? 'Không có vị trí'}
⚠️ Mức độ: ${alert.severity.viName}
📅 ${AlertDateTimeHelper.format(alert.createdAt)}
    ''';

    Clipboard.setData(ClipboardData(text: shareText));
    Get.snackbar(
      'Đã sao chép',
      'Thông tin cảnh báo đã được sao chép. Bạn có thể chia sẻ qua ứng dụng khác.',
      duration: const Duration(seconds: 3),
    );
  }

  void _reportAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo cảnh báo'),
        content: const Text(
          'Bạn có muốn báo cáo cảnh báo này là không chính xác hoặc không phù hợp?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Đã gửi báo cáo',
                'Cảm ơn bạn đã báo cáo. Chúng tôi sẽ xem xét.',
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Báo cáo'),
          ),
        ],
      ),
    );
  }
}

// Private widget: App Bar
class _AlertDetailAppBar extends StatelessWidget {
  final AlertEntity alert;
  final Color severityColor;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _AlertDetailAppBar({
    required this.alert,
    required this.severityColor,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: severityColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          alert.alertType.viName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                severityColor,
                severityColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              AlertTypeHelper.getIcon(alert.alertType),
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.share, color: Colors.white),
          tooltip: 'Chia sẻ',
        ),
        IconButton(
          onPressed: onReport,
          icon: const Icon(Icons.report, color: Colors.white),
          tooltip: 'Báo cáo',
        ),
      ],
    );
  }
}

// Private widget: Header Section
class _HeaderSection extends StatelessWidget {
  final AlertEntity alert;
  final Color severityColor;

  const _HeaderSection({
    required this.alert,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      color: severityColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BadgesRow(alert: alert, severityColor: severityColor),
          const SizedBox(height: 16),
          Text(
            alert.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _TimeInfoRow(alert: alert),
        ],
      ),
    );
  }
}

// Private widget: Badges Row
class _BadgesRow extends StatelessWidget {
  final AlertEntity alert;
  final Color severityColor;

  const _BadgesRow({
    required this.alert,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Badge(
          color: severityColor,
          icon: Icons.warning,
          label: alert.severity.viName,
        ),
        const SizedBox(width: 12),
        _Badge(
          color: Colors.blue.shade700,
          icon: Iconsax.people,
          label: alert.targetAudience.viName,
        ),
      ],
    );
  }
}

// Private widget: Single Badge
class _Badge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _Badge({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Private widget: Time Info Row
class _TimeInfoRow extends StatelessWidget {
  final AlertEntity alert;

  const _TimeInfoRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Iconsax.clock, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            AlertDateTimeHelper.format(alert.createdAt),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (alert.expiresAt != null) ...[
          const SizedBox(width: 16),
          Icon(Iconsax.timer, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Hết hạn: ${AlertDateTimeHelper.format(alert.expiresAt!)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

// Private widget: Content Section
class _ContentSection extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onShare;

  const _ContentSection({
    required this.alert,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlertSectionTitle(title: 'Nội dung'),
          const SizedBox(height: 12),
          Text(
            alert.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (alert.location != null || 
              (alert.lat != null && alert.lng != null))
            _LocationSection(alert: alert),
          if (alert.imageUrls != null && alert.imageUrls!.isNotEmpty)
            _ImagesSection(imageUrls: alert.imageUrls!),
          if (alert.safetyGuide != null && alert.safetyGuide!.isNotEmpty)
            _SafetyGuideSection(safetyGuide: alert.safetyGuide!),
          _ActionButtonsSection(alert: alert, onShare: onShare),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Private widget: Location Section
class _LocationSection extends StatelessWidget {
  final AlertEntity alert;

  const _LocationSection({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AlertSectionTitle(title: 'Vị trí'),
        const SizedBox(height: 12),
        AlertInfoCard(
          icon: Iconsax.location,
          title: 'Địa điểm',
          content: alert.location ?? 
                   '${alert.lat?.toStringAsFixed(6)}, ${alert.lng?.toStringAsFixed(6)}',
          color: Colors.blue,
        ),
        if (alert.province != null || alert.district != null) ...[
          const SizedBox(height: 8),
          AlertInfoCard(
            icon: Iconsax.map,
            title: 'Khu vực',
            content: [
              if (alert.district != null) alert.district!,
              if (alert.province != null) alert.province!,
            ].join(', '),
            color: Colors.green,
          ),
        ],
        if (alert.radiusKm != null) ...[
          const SizedBox(height: 8),
          AlertInfoCard(
            icon: Iconsax.radar,
            title: 'Bán kính ảnh hưởng',
            content: '${alert.radiusKm} km',
            color: Colors.orange,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// Private widget: Images Section
class _ImagesSection extends StatelessWidget {
  final List<String> imageUrls;

  const _ImagesSection({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AlertSectionTitle(title: 'Hình ảnh'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return _ImageItem(imageUrl: imageUrls[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Private widget: Image Item
class _ImageItem extends StatelessWidget {
  final String imageUrl;

  const _ImageItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 300,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }
}

// Private widget: Safety Guide Section
class _SafetyGuideSection extends StatelessWidget {
  final String safetyGuide;

  const _SafetyGuideSection({required this.safetyGuide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlertExpandableSection(
          title: 'Hướng dẫn an toàn',
          icon: Iconsax.shield_tick,
          content: safetyGuide,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Private widget: Action Buttons Section
class _ActionButtonsSection extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onShare;

  const _ActionButtonsSection({
    required this.alert,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrimaryActionButton(alert: alert),
        const SizedBox(height: 12),
        _SecondaryActionButtons(alert: alert, onShare: onShare),
      ],
    );
  }
}

// Private widget: Primary Action Button
class _PrimaryActionButton extends StatelessWidget {
  final AlertEntity alert;

  const _PrimaryActionButton({required this.alert});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _handleMapAction(),
        icon: const Icon(Iconsax.map),
        label: Text(
          alert.lat != null && alert.lng != null
              ? 'Xem trên bản đồ'
              : 'Tìm nơi trú ẩn gần nhất',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: MinhColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _handleMapAction() {
    if (alert.lat != null && alert.lng != null) {
      // TODO: Navigate to map with alert location
      Get.snackbar(
        'Thông báo',
        'Chức năng xem trên bản đồ sẽ được cập nhật',
      );
    }
  }
}

// Private widget: Secondary Action Buttons
class _SecondaryActionButtons extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onShare;

  const _SecondaryActionButtons({
    required this.alert,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Iconsax.share, size: 18),
            label: const Text('Chia sẻ'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleCopyCoordinates(),
            icon: const Icon(Iconsax.copy, size: 18),
            label: const Text('Sao chép'),
          ),
        ),
      ],
    );
  }

  void _handleCopyCoordinates() {
    if (alert.lat != null && alert.lng != null) {
      Clipboard.setData(
        ClipboardData(text: '${alert.lat}, ${alert.lng}'),
      );
      Get.snackbar(
        'Đã sao chép',
        'Tọa độ đã được sao chép vào clipboard',
      );
    }
  }
}

import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_badge.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_timer.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/repositories/donation_plan_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_location_map_screen.dart';
import 'package:cuutrobaolu/presentation/features/common/widgets/alert_detail_widgets.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/donation/victim_donation_screen.dart';
import 'package:cuutrobaolu/data/services/engagement_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertDetailScreen extends StatefulWidget {
  final AlertEntity alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  final _engagementTracker = EngagementTracker();
  
  @override
  void initState() {
    super.initState();
    // Track alert view when screen opens
    _engagementTracker.initialize();
    _trackView();
  }
  
  void _trackView() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    _engagementTracker.trackView(widget.alert, userId);
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = AlertSeverityHelper.getColor(widget.alert.severity);

    return Scaffold(
      appBar: _AlertDetailAppBar(
        alert: widget.alert,
        severityColor: severityColor,
        onShare: _shareAlert,
        onInfo: () => _reportAlert(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(alert: widget.alert, severityColor: severityColor),
            _ContentSection(alert: widget.alert, onShare: _shareAlert),
          ],
        ),
      ),
    );
  }

  void _shareAlert() {
    // Track share engagement
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    _engagementTracker.trackShare(widget.alert, userId);
    
    final shareText = '''
🚨 ${widget.alert.title}

${widget.alert.content}

📍 ${widget.alert.location ?? 'Không có vị trí'}
⚠️ Mức độ: ${widget.alert.severity.viName}
📅 ${AlertDateTimeHelper.format(widget.alert.createdAt)}
    ''';

    Clipboard.setData(ClipboardData(text: shareText));
    Get.snackbar(
      'Đã sao chép',
      'Thông tin cảnh báo đã được sao chép. Bạn có thể chia sẻ qua ứng dụng khác.',
      duration: const Duration(seconds: 3),
    );
  }

  void _reportAlert(BuildContext context) {
    // Track report engagement
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    _engagementTracker.trackReport(widget.alert, userId);

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
class _AlertDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AlertEntity alert;
  final Color severityColor;
  final VoidCallback onShare;
  final VoidCallback onInfo;

  const _AlertDetailAppBar({
    required this.alert,
    required this.severityColor,
    required this.onShare,
    required this.onInfo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: severityColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Quay lại',
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AlertTypeHelper.getIcon(alert.alertType),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              alert.alertType.viName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: onShare,
          icon: const Icon(Iconsax.share, color: Colors.white),
          tooltip: 'Chia sẻ',
        ),
        IconButton(
          onPressed: onInfo,
          icon: const Icon(Iconsax.info_circle, color: Colors.white),
          tooltip: 'Thông tin',
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
        AlertBadge(
          label: alert.severity.viName,
          color: severityColor,
          icon: Iconsax.danger,
          size: BadgeSize.medium,
          variant: BadgeVariant.filled,
        ),
        const SizedBox(width: 12),
        AlertBadge(
          label: alert.targetAudience.viName,
          color: Colors.blue.shade700,
          icon: Iconsax.people,
          size: BadgeSize.medium,
          variant: BadgeVariant.filled,
        ),
      ],
    );
  }
}

// Private widget: Time Info Row
class _TimeInfoRow extends StatelessWidget {
  final AlertEntity alert;

  const _TimeInfoRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
          ],
        ),
        if (alert.expiresAt != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Iconsax.timer, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Hết hạn: ${AlertDateTimeHelper.format(alert.expiresAt!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedAlertTimer(
            expiresAt: alert.expiresAt!,
            showIcon: true,
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alert.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (alert.location != null || 
              (alert.lat != null && alert.lng != null))
            _LocationSection(alert: alert),
          if (alert.imageUrls != null && alert.imageUrls!.isNotEmpty)
            _ImagesSection(imageUrls: alert.imageUrls!),
          if (alert.safetyGuide != null && alert.safetyGuide!.isNotEmpty)
            _SafetyGuideSection(safetyGuide: alert.safetyGuide!),
          _DonationSection(alert: alert),
          const SizedBox(height: 16),
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
    final radiusKm = alert.radiusKm;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AlertSectionTitle(title: 'Vị trí'),
        const SizedBox(height: 12),
        // Blue card for location
        AlertInfoCard(
          icon: Iconsax.location,
          title: 'Địa điểm',
          content: alert.location ?? 
                   '${alert.lat?.toStringAsFixed(6)}, ${alert.lng?.toStringAsFixed(6)}',
          color: Colors.blue.shade700,
        ),
        // Green card for area
        if (alert.province != null || alert.district != null) ...[
          const SizedBox(height: 8),
          AlertInfoCard(
            icon: Iconsax.map,
            title: 'Khu vực',
            content: [
              if (alert.district != null) alert.district!,
              if (alert.province != null) alert.province!,
            ].join(', '),
            color: Colors.green.shade700,
          ),
        ],
        // Orange card for radius
        if (radiusKm != null) ...[
          const SizedBox(height: 8),
          AlertInfoCard(
            icon: Iconsax.timer,
            title: 'Bán kính ảnh hưởng',
            content: '${radiusKm.toStringAsFixed(1)} km',
            color: Colors.orange.shade700,
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

// Private widget: Donation Section
class _DonationSection extends StatefulWidget {
  final AlertEntity alert;

  const _DonationSection({required this.alert});

  @override
  State<_DonationSection> createState() => _DonationSectionState();
}

class _DonationSectionState extends State<_DonationSection> {
  final DonationPlanRepository _planRepo = getIt<DonationPlanRepository>();
  bool _isLoading = false;
  bool _hasPlan = false;

  @override
  void initState() {
    super.initState();
    _checkDonationPlan();
  }

  Future<void> _checkDonationPlan() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _planRepo.getPlansByAlert(widget.alert.id);
      setState(() {
        _hasPlan = plans.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_hasPlan) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AlertSectionTitle(title: 'Quyên góp'),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.heart, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Hỗ trợ khu vực này",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                Text(
                  "Khu vực này đang cần sự hỗ trợ. Bạn có thể quyên góp tiền, vật phẩm hoặc thời gian để giúp đỡ.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => VictimDonationScreen());
                    },
                    icon: Icon(Iconsax.heart),
                    label: Text("Quyên góp ngay"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      Get.to(() => AlertLocationMapScreen(alert: alert));
    } else {
      Get.snackbar(
        'Thông báo',
        'Cảnh báo này không có thông tin vị trí',
        snackPosition: SnackPosition.BOTTOM,
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

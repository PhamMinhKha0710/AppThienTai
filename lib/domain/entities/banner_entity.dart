/// Banner Entity - Pure business object
/// Không có dependencies vào Firebase, Flutter, hay external packages
class BannerEntity {
  final String id;
  final String imageUrl;
  final String targetScreen;
  final String name;
  final bool active;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.targetScreen,
    required this.name,
    required this.active,
  });

  BannerEntity copyWith({
    String? id,
    String? imageUrl,
    String? targetScreen,
    String? name,
    bool? active,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      targetScreen: targetScreen ?? this.targetScreen,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }
}



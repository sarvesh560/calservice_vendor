class PromotionModel {
  const PromotionModel({
    required this.id,
    required this.partnerName,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.logoAsset,
    required this.ctaText,
    required this.externalUrl,
    this.badgeText = 'PARTNER SPOTLIGHT',
    this.isActive = true,
  });

  final String id;
  final String partnerName;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String logoAsset;
  final String ctaText;
  final String externalUrl;
  final String badgeText;
  final bool isActive;

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String? ?? '',
      partnerName: json['partner_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageAsset: json['image_asset'] as String? ?? '',
      logoAsset: json['logo_asset'] as String? ?? '',
      ctaText: json['cta_text'] as String? ?? 'Explore Now',
      externalUrl: json['external_url'] as String? ?? 'https://calservice.in',
      badgeText: json['badge_text'] as String? ?? 'PARTNER SPOTLIGHT',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_name': partnerName,
      'title': title,
      'subtitle': subtitle,
      'image_asset': imageAsset,
      'logo_asset': logoAsset,
      'cta_text': ctaText,
      'external_url': externalUrl,
      'badge_text': badgeText,
      'is_active': isActive,
    };
  }
}

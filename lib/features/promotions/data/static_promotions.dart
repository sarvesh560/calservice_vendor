import '../models/promotion_model.dart';

const staticPromotions = <PromotionModel>[
  PromotionModel(
    id: 'promo_proconnect',
    partnerName: 'ProConnect',
    title: 'Grow Your Business',
    subtitle: 'Discover new service opportunities, commercial tools, and business growth programs.',
    imageAsset: 'assets/promotions/proconnect.webp',
    logoAsset: 'assets/promotions/proconnect.webp',
    ctaText: 'Explore Now',
    externalUrl: 'https://calservice.in/proconnect',
    badgeText: 'PARTNER SPOTLIGHT',
  ),
  PromotionModel(
    id: 'promo_skillforge',
    partnerName: 'SkillForge',
    title: 'Upgrade Your Skills',
    subtitle: 'Access certified technical courses and take your service expertise further.',
    imageAsset: 'assets/promotions/skillforge.webp',
    logoAsset: 'assets/promotions/skillforge.webp',
    ctaText: 'Learn More',
    externalUrl: 'https://calservice.in/skillforge',
    badgeText: 'TECHNICAL ACADEMY',
  ),
  PromotionModel(
    id: 'promo_workplus',
    partnerName: 'WorkPlus',
    title: 'Exclusive Benefits',
    subtitle: 'Special equipment discounts and health coverage crafted for workforce vendors.',
    imageAsset: 'assets/promotions/workplus.webp',
    logoAsset: 'assets/promotions/workplus.webp',
    ctaText: 'View Offer',
    externalUrl: 'https://calservice.in/workplus',
    badgeText: 'VENDOR PERKS',
  ),
];

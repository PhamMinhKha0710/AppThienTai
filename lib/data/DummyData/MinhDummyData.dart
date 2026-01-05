import '../../domain/entities/banner_entity.dart';
import 'package:cuutrobaolu/presentation/features/home/models/help_request_modal.dart';
import 'package:cuutrobaolu/presentation/features/home/models/supporter_modal.dart';

import 'package:cuutrobaolu/presentation/routes/routes.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';

class MinhDummyData {

  static final List<BannerEntity> banners = [
    BannerEntity(
      id: "promoBanner1",
      name: "promoBanner1",
      imageUrl: MinhImages.promoBanner1,
      active: false,
      targetScreen: MinhRoutes.welcome,
    ),
    BannerEntity(
      id: "promoBanner2",
      name: "promoBanner2",
      imageUrl: MinhImages.promoBanner2,
      active: false,
      targetScreen: MinhRoutes.checkout,
    ),
    BannerEntity(
      id: "promoBanner3",
      name: "promoBanner3",
      imageUrl: MinhImages.promoBanner3,
      active: false,
      targetScreen: MinhRoutes.eComDashboard,
    ),
    BannerEntity(
      id: "banner2",
      name: "banner2",
      imageUrl: MinhImages.banner2,
      active: false,
      targetScreen: MinhRoutes.cart,
    ),
    BannerEntity(
      id: "banner3",
      name: "banner3",
      imageUrl: MinhImages.banner3,
      active: false,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "banner4",
      name: "banner4",
      imageUrl: MinhImages.banner4,
      active: false,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerCoby_1",
      name: "bannerCoby_1",
      imageUrl: MinhImages.bannerCoby_1,
      active: true,
      targetScreen: MinhRoutes.checkout,
    ),
    BannerEntity(
      id: "bannerLuffy_1",
      name: "bannerLuffy_1",
      imageUrl: MinhImages.bannerLuffy_1,
      active: true,
      targetScreen: MinhRoutes.eComDashboard,
    ),
    BannerEntity(
      id: "bannerLuffy_2",
      name: "bannerLuffy_2",
      imageUrl: MinhImages.bannerLuffy_2,
      active: true,
      targetScreen: MinhRoutes.cart,
    ),
    BannerEntity(
      id: "bannerZoro_1",
      name: "bannerZoro_1",
      imageUrl: MinhImages.bannerZoro_1,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerZoro_2",
      name: "bannerZoro_2",
      imageUrl: MinhImages.bannerZoro_2,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerZoro_3",
      name: "bannerZoro_3",
      imageUrl: MinhImages.bannerZoro_3,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerSanji_1",
      name: "bannerSanji_1",
      imageUrl: MinhImages.bannerSanji_1,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerSanji_2",
      name: "bannerSanji_2",
      imageUrl: MinhImages.bannerSanji_2,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerLuffy_3",
      name: "bannerLuffy_3",
      imageUrl: MinhImages.bannerLuffy_3,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerLuffy_4",
      name: "bannerLuffy_4",
      imageUrl: MinhImages.bannerLuffy_4,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerEntity(
      id: "bannerLuffy_5",
      name: "bannerLuffy_5",
      imageUrl: MinhImages.bannerLuffy_5,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
  ];



  static final List<HelpRequest> helps = [

      HelpRequest(
        id: "1",
        title: 'Cần gạo - Đà Nẵng',
        description: 'Ngập nặng, cần 50kg gạo',
        lat: 16.0678,
        lng: 108.2208,
        contact: '0123456789',
        severity: RequestSeverity.medium,
        address: 'Đà Nẵng',
      ),
      HelpRequest(
        id: "2",
        title: 'Cần thuốc - Quảng Nam',
        description: 'Bệnh nhân cần thuốc kháng sinh',
        lat: 15.8780,
        lng: 108.3475,
        contact: '0987654321',
        severity: RequestSeverity.medium,
        address: 'Quảng Nam',
      ),

  ];
  static final List<SupporterModel> supporters = [

    SupporterModel(
      id: "1",
      name: 'Nhà hảo tâm A',
      lat: 16.0700,
      lng: 108.2300,
      capacity: 5,
      userId: '',
    ),
    SupporterModel(
      id: "2",
      name: 'Tổ chức B',
      lat: 15.8800,
      lng: 108.3400,
      capacity: 10,
      userId: '',
    ),
    SupporterModel(
      id: "3",
      name: 'Tình nguyện viên C',
      lat: 15.9000,
      lng: 108.3000,
      capacity: 2,
      userId: '',
    ),

  ];
}

import 'package:cuutrobaolu/presentation/features/shop/models/banner_model.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/supporter_modal.dart';

import 'package:cuutrobaolu/presentation/routes/routes.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';

class MinhDummyData {


  // static final List<BannerModel> banners = [
  //   BannerModel(name: MinhImages.promoBanner1, imageUrl: MinhImages.promoBanner1, active: true , targetScreen: MinhRoutes.welcome),
  //   BannerModel(name: MinhImages.promoBanner2, imageUrl: MinhImages.promoBanner2, active: true, targetScreen: MinhRoutes.checkout),
  //   BannerModel(name: MinhImages.promoBanner3, imageUrl: MinhImages.promoBanner3, active: true, targetScreen: MinhRoutes.eComDashboard),
  //   BannerModel(name: MinhImages.banner2, imageUrl: MinhImages.banner2, active: true, targetScreen: MinhRoutes.cart ),
  //   BannerModel(name: MinhImages.banner3, imageUrl: MinhImages.banner3, active: true, targetScreen: MinhRoutes.userProfile),
  //   BannerModel(name: MinhImages.banner4, imageUrl: MinhImages.banner4, active: true, targetScreen: MinhRoutes.userProfile),
  //
  //
  // ];


  static final List<BannerModel> banners = [
    BannerModel(
      name: "promoBanner1",
      imageUrl: MinhImages.promoBanner1,
      active: false,
      targetScreen: MinhRoutes.welcome,
    ),
    BannerModel(
      name: "promoBanner2",
      imageUrl: MinhImages.promoBanner2,
      active: false,
      targetScreen: MinhRoutes.checkout,
    ),
    BannerModel(
      name: "promoBanner3",
      imageUrl: MinhImages.promoBanner3,
      active: false,
      targetScreen: MinhRoutes.eComDashboard,
    ),
    BannerModel(
      name: "banner2",
      imageUrl: MinhImages.banner2,
      active: false,
      targetScreen: MinhRoutes.cart,
    ),
    BannerModel(
      name: "banner3",
      imageUrl: MinhImages.banner3,
      active: false,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "banner4",
      imageUrl: MinhImages.banner4,
      active: false,
      targetScreen: MinhRoutes.userProfile,
    ),

    BannerModel(
      name: "bannerCoby_1",
      imageUrl: MinhImages.bannerCoby_1,
      active: true,
      targetScreen: MinhRoutes.checkout,
    ),
    BannerModel(
      name: "bannerLuffy_1",
      imageUrl: MinhImages.bannerLuffy_1,
      active: true,
      targetScreen: MinhRoutes.eComDashboard,
    ),
    BannerModel(
      name: "bannerLuffy_2",
      imageUrl: MinhImages.bannerLuffy_2,
      active: true,
      targetScreen: MinhRoutes.cart,
    ),
    BannerModel(
      name: "bannerZoro_1",
      imageUrl: MinhImages.bannerZoro_1,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerZoro_2",
      imageUrl: MinhImages.bannerZoro_2,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerZoro_3",
      imageUrl: MinhImages.bannerZoro_3,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerSanji_1",
      imageUrl: MinhImages.bannerSanji_1,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerSanji_2",
      imageUrl: MinhImages.bannerSanji_2,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerLuffy_3",
      imageUrl: MinhImages.bannerLuffy_3,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
      name: "bannerLuffy_4",
      imageUrl: MinhImages.bannerLuffy_4,
      active: true,
      targetScreen: MinhRoutes.userProfile,
    ),
    BannerModel(
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

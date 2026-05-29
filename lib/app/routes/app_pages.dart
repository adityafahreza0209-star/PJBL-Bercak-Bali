import 'package:get/get.dart';

import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/destination_city/bindings/destination_city_binding.dart';
import '../modules/destination_city/views/destination_city_view.dart';
import '../modules/detail_restoran/bindings/detail_restoran_binding.dart';
import '../modules/detail_restoran/views/detail_restoran_view.dart';
import '../modules/detail_wisata/bindings/detail_wisata_binding.dart';
import '../modules/detail_wisata/views/detail_wisata_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/jelajahi/bindings/jelajahi_binding.dart';
import '../modules/jelajahi/views/jelajahi_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/my_reviews/bindings/my_reviews_binding.dart';
import '../modules/my_reviews/views/my_reviews_view.dart';
import '../modules/privacy_security/bindings/privacy_security_binding.dart';
import '../modules/privacy_security/views/privacy_security_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/simpan/bindings/simpan_binding.dart';
import '../modules/simpan/views/simpan_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';
import '../modules/write_review/bindings/write_review_binding.dart';
import '../modules/write_review/views/write_review_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.JELAJAHI,
      page: () => const JelajahiView(),
      binding: JelajahiBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_WISATA,
      page: () => const DetailWisataView(),
      binding: DetailWisataBinding(),
    ),
    GetPage(
      name: _Paths.SIMPAN,
      page: () => const SimpanView(),
      binding: SimpanBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.DESTINATION_CITY,
      page: () => const DestinationCityView(),
      binding: DestinationCityBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_RESTORAN,
      page: () => const DetailRestoranView(),
      binding: DetailRestoranBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_SECURITY,
      page: () => const PrivacySecurityView(),
      binding: PrivacySecurityBinding(),
    ),
    GetPage(
      name: _Paths.MY_REVIEWS,
      page: () => const MyReviewsView(),
      binding: MyReviewsBinding(),
    ),
    GetPage(
      name: _Paths.WRITE_REVIEW,
      page: () => const WriteReviewView(),
      binding: WriteReviewBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
  ];
}

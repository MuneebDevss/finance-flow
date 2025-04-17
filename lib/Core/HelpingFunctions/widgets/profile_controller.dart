import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Auth/Presentation/login_page.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final _isLoading = false.obs;
  final _user = Rx<UserEntity?>(null);
  final UsersRepository authRepository = Get.put(UsersRepository());

  bool get isLoading => _isLoading.value;
  UserEntity? get user => _user.value;
  set user (UserEntity? value) => _user.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      _isLoading.value = true;
      final userData = await authRepository.fetchCurrentUser();
      _user.value = userData;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.logoutUser(); // Assuming you have this method
      Get.offAll(() => const LoginPage());
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
}

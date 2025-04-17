import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarController extends GetxController {
  static const String AVATAR_KEY = 'selected_avatar_path';
  final Rx<String?> selectedAvatarPath = Rx<String?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadAvatar();
  }

  Future<void> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    selectedAvatarPath.value = prefs.getString(AVATAR_KEY);
  }

  Future<void> saveAvatar(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(AVATAR_KEY);
    } else {
      await prefs.setString(AVATAR_KEY, path);
    }
    selectedAvatarPath.value = path;
  }

  void showAvatarSelectionDialog() {
    final List<String> avatarOptions = [
      'assets/images/avatar.png',
      'assets/images/avatar1.png',
      'assets/images/avatar2.png',
      'assets/images/avatar3.png',
      'assets/images/avatar4.png',
      'assets/images/avatar5.png',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  // No avatar option
                  GestureDetector(
                    onTap: () {
                      saveAvatar(null);
                      Get.back();
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Avatar options
                  ...avatarOptions.map((path) => GestureDetector(
                    onTap: () {
                      saveAvatar(path);
                      Get.back();
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(path),
                    ),
                  )).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectableAvatar extends StatelessWidget {
  SelectableAvatar({super.key});

  final AvatarController controller = Get.put(AvatarController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.showAvatarSelectionDialog,
      child: Obx(() {
        final avatarPath = controller.selectedAvatarPath.value;
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: avatarPath != null ? AssetImage(avatarPath) : null,
          child: avatarPath == null
              ? const Icon(
                  Icons.edit,
                  size: 40,
                  color: Colors.grey,
                )
              : null,
        );
      }),
    );
  }
}
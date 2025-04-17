
import 'package:finance/Core/HelpingFunctions/widgets/profile_controller.dart';
import 'package:finance/Core/constants/color_palette.dart';
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Auth/Presentation/edit_user_profile.dart';
import 'package:finance/Features/Income/Presentation/Widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ProfileController controller = Get.put(ProfileController());
  @override
  void initState(){
    controller.fetchUserData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(()=>EditProfilePage(currentUser: controller.user!, authRepository: controller.authRepository));
              },
              ),
              SizedBox(width: Sizes.spaceBtwItems,)
        ],
        title: Row(
          children: [
            Icon(Icons.person),
            SizedBox(width: Sizes.spaceBtwItems,),
            Text(
              'My Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.user == null) {
          return const Center(child: Text('No profile data available'));
        }

        final user = controller.user!;
        
        return ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                SelectableAvatar(),
                const SizedBox(height: Sizes.spaceBtwItems),
                Divider(
                  indent: Sizes.defaultSpace,
                  endIndent: Sizes.defaultSpace,
                  color: TColors.grey.withOpacity(0.5),
                  thickness: 2,
                ),
              ],
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  MyInfoRow(
                    title: 'Name',
                    info: user.name,
                    icon: const Icon(Icons.person, size: Sizes.iconLg / 1.6),
                  ),
                  MyInfoRow(
                    title: 'Email',
                    info: user.email,
                    icon: const Icon(Icons.email, size: Sizes.iconLg / 1.6),
                  ),
                  MyInfoRow(
                    title: 'Phone Number',
                    info: user.phoneNumber,
                    icon: const Icon(Icons.phone, size: Sizes.iconLg / 1.6),
                  ),
                  MyInfoRow(
                    title: 'Date of Birth',
                    info: DateFormat('dd MMM, yyyy').format(user.dateOfBirth),
                    icon: const Icon(Icons.calendar_today, size: Sizes.iconLg / 1.6),
                  ),
                  MyInfoRow(
                    title: 'Preferred Currency',
                    info: user.preferedCurrency,
                    icon: const Icon(Icons.currency_exchange, size: Sizes.iconLg / 1.6),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Divider(
                    color: TColors.grey.withOpacity(0.5),
                    thickness: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
              child: TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => controller.signOut(),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.labelSmall!.apply(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
class MyInfoRow extends StatelessWidget {
  final String title;
  final String info;
  final Widget icon;
  final VoidCallback? onTap;

  const MyInfoRow({
    super.key,
    required this.title,
    required this.info,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                child: icon,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null) 
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
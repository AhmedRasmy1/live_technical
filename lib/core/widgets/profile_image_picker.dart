import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';

/// Circular grey placeholder with an image icon and a camera badge.
/// Image upload is not wired yet (imageUrl is optional).
class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Choose employee image',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: AppConstants.avatarPickerRadius,
              backgroundColor: context.colors.lightGrey,
              child: Icon(
                Icons.image_outlined,
                size: AppConstants.iconSize,
                color: context.colors.textPrimary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: AppConstants.avatarBadgeRadius,
                backgroundColor: context.colors.lightGrey,
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: AppConstants.captionSize,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';

/// Circular avatar showing [imageUrl], or a person icon when there is none.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = AppConstants.avatarRadius,
  });

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.colors.lightGrey,
      backgroundImage: hasImage ? NetworkImage(url) : null,
      child: hasImage
          ? null
          : Icon(
              Icons.person,
              size: AppConstants.iconSize,
              color: context.colors.grey,
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    this.onMessagePressed,
  });

  final EmployeeEntity employee;
  final VoidCallback? onMessagePressed;

  @override
  Widget build(BuildContext context) {
    final imageUrl = employee.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppPadding.p12),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: AppConstants.avatarRadius,
                backgroundColor: ColorManager.fieldFill,
                backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.person,
                        size: AppConstants.iconSize,
                        color: ColorManager.grey,
                      ),
              ),
            ),
            const SizedBox(width: AppPadding.p12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getMediumStyle(
                      fontSize: AppConstants.bodySize,
                      color: ColorManager.black,
                    ),
                  ),
                  Text(
                    employee.jobTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: AppConstants.captionSize,
                      color: ColorManager.textGrey,
                    ),
                  ),
                  Text(
                    employee.department,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: AppConstants.captionSize,
                      color: ColorManager.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppPadding.p8),
            Align(
              alignment: Alignment.bottomRight,
              child: AppActionButton(
                label: 'Message',
                icon: Icons.chat_bubble_outline,
                fontSize: AppConstants.captionSize,
                iconSize: AppConstants.smallIconSize,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p4,
                ),
                onPressed: onMessagePressed ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

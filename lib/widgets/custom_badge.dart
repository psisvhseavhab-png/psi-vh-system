import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const CustomBadge({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  }) : super(key: key);

  factory CustomBadge.success(String text, {IconData? icon}) {
    return CustomBadge(
      label: text,
      backgroundColor: AppColors.lightGreen,
      textColor: AppColors.successGreen,
      icon: icon ?? Icons.check_circle_outline,
    );
  }

  factory CustomBadge.warning(String text, {IconData? icon}) {
    return CustomBadge(
      label: text,
      backgroundColor: AppColors.lightOrange,
      textColor: AppColors.warningOrange,
      icon: icon ?? Icons.schedule,
    );
  }

  factory CustomBadge.danger(String text, {IconData? icon}) {
    return CustomBadge(
      label: text,
      backgroundColor: AppColors.lightRed,
      textColor: AppColors.dangerRed,
      icon: icon ?? Icons.cancel_outlined,
    );
  }

  factory CustomBadge.info(String text, {IconData? icon}) {
    return CustomBadge(
      label: text,
      backgroundColor: AppColors.lightBlue,
      textColor: AppColors.primaryBlue,
      icon: icon ?? Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}


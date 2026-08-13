import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? subtitle;
  final bool isDarkTheme;

  const FinancialCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primaryBlue,
    this.iconBgColor = const Color(0xFFEFF6FF),
    this.subtitle,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDarkTheme ? AppColors.darkSlateCard : Colors.white;

    final borderColor =
        isDarkTheme ? AppColors.darkSlateBorder : AppColors.lightBorder;

    final titleColor =
        isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final valueColor =
        isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final mutedColor =
        isDarkTheme ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: isDarkTheme
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium(
                    color: titleColor,
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  icon,
                  size: 18.0,
                  color: iconColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.numericData(
                color: valueColor,
                fontSize: 20.0,
              ),
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 2.0),

            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(
                color: mutedColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
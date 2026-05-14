import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'brutal_card.dart';

class BrutalButton extends StatelessWidget {
  const BrutalButton({
    required this.label,
    required this.onTap,
    super.key,
    this.icon,
    this.backgroundColor,
    this.foregroundColor = AppColors.blackStroke,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.lg,
      vertical: AppSizes.md,
    ),
    this.width,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: BrutalCard(
        width: width,
        onTap: onTap,
        padding: padding,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: AppSizes.sm),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class BrutalCard extends StatelessWidget {
  const BrutalCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.backgroundColor,
    this.borderColor = AppColors.blackStroke,
    this.shadowColor = AppColors.blackStroke,
    this.borderWidth = AppSizes.brutalBorder,
    this.borderRadius = AppSizes.brutalRadius,
    this.shadowOffset = AppSizes.brutalShadowOffset,
    this.width,
    this.height,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? Theme.of(context).cardColor;
    final foregroundColor = cardColor.computeLuminance() > 0.45
        ? AppColors.blackStroke
        : AppColors.darkText;
    final themedChild = Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: foregroundColor),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: foregroundColor,
          displayColor: foregroundColor,
        ),
      ),
      child: child,
    );
    final radius = BorderRadius.circular(borderRadius);
    final card = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: themedChild,
    );

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          right: shadowOffset.dx.abs(),
          bottom: shadowOffset.dy.abs(),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: shadowOffset.dx,
              top: shadowOffset.dy,
              right: -shadowOffset.dx,
              bottom: -shadowOffset.dy,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: radius,
                ),
              ),
            ),
            card,
          ],
        ),
      ),
    );
  }
}

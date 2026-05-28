import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/brutal_card.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: BrutalCard(
              backgroundColor: AppColors.creamBackground,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xl,
                vertical: AppSizes.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.blackStroke,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        size: 48,
                        color: AppColors.blackStroke,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Plan boldly. Finish loudly.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    const _BrutalLoadingDots(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrutalLoadingDots extends StatefulWidget {
  const _BrutalLoadingDots();

  @override
  State<_BrutalLoadingDots> createState() => _BrutalLoadingDotsState();
}

class _BrutalLoadingDotsState extends State<_BrutalLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final wave = math.sin((_controller.value * math.pi * 2) + index);
            return Transform.translate(
              offset: Offset(0, -6 * wave),
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: [
                    AppColors.primaryYellow,
                    AppColors.pink,
                    AppColors.mintGreen,
                  ][index],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.blackStroke, width: 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

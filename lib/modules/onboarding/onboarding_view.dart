import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _pages = [
    _OnboardingPageData(
      title: 'Plan & Focus Boldly',
      message:
          'Create tasks, pick priorities, and focus on what matters today.',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primaryYellow,
    ),
    _OnboardingPageData(
      title: 'Track Your Wins',
      message: 'Complete tasks, build streaks, and see your progress grow.',
      icon: Icons.emoji_events_rounded,
      color: AppColors.mintGreen,
    ),
    _OnboardingPageData(
      title: 'Offline Always',
      message: 'No login. No internet. Your tasks stay on your phone.',
      icon: Icons.phone_android_rounded,
      color: AppColors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            return Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.onPageChanged,
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            final page = _pages[index];
                            return _OnboardingPage(
                              page: page,
                              showFinalInputs: index == _pages.length - 1,
                              isWide: isWide,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            final selected =
                                controller.currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: selected ? 28 : 12,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.blackStroke
                                    : AppColors.blackStroke.withValues(
                                        alpha: 0.18,
                                      ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Obx(
                        () => BrutalButton(
                          width: double.infinity,
                          label: controller.isLastPage ? 'Get Started' : 'Next',
                          icon: controller.isLastPage
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          onTap: controller.nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends GetView<OnboardingController> {
  const _OnboardingPage({
    required this.page,
    required this.showFinalInputs,
    required this.isWide,
  });

  final _OnboardingPageData page;
  final bool showFinalInputs;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final illustration = BrutalCard(
      backgroundColor: page.color,
      padding: const EdgeInsets.all(AppSizes.xl),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 12,
              right: 18,
              child: _AccentSquare(color: AppColors.pink),
            ),
            Positioned(
              bottom: 12,
              left: 18,
              child: _AccentSquare(color: AppColors.mintGreen),
            ),
            Icon(page.icon, size: 104, color: AppColors.blackStroke),
          ],
        ),
      ),
    );

    final copy = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          page.title,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          page.message,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (showFinalInputs) ...[
          const SizedBox(height: AppSizes.xl),
          BrutalTextField(
            controller: controller.usernameController,
            labelText: 'Username',
            hintText: 'Task Hero',
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.person_rounded),
          ),
          const SizedBox(height: AppSizes.md),
          BrutalCard(
            backgroundColor: AppColors.mintGreen,
            padding: const EdgeInsets.all(AppSizes.md),
            shadowOffset: const Offset(3, 3),
            child: Obx(
              () => Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.blackStroke),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Daily goal: ${controller.dailyGoal.value} tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Decrease daily goal',
                    onPressed: controller.decrementGoal,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  IconButton(
                    tooltip: 'Increase daily goal',
                    onPressed: controller.incrementGoal,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: illustration),
                  const SizedBox(width: AppSizes.xxl),
                  Expanded(child: copy),
                ],
              )
            : Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: illustration,
                  ),
                  const SizedBox(height: AppSizes.xxl),
                  copy,
                ],
              ),
      ),
    );
  }
}

class _AccentSquare extends StatelessWidget {
  const _AccentSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.3,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.blackStroke, width: 3),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}

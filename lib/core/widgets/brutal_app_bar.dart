import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class BrutalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrutalAppBar({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../calendar_controller.dart';

class MonthControlBar extends StatelessWidget {
  final CalendarController controller;

  const MonthControlBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Obx(() {
            final date = controller.currentMonth.value;
            final monthName = DateFormat('MMMM').format(date);
            final year = DateFormat('yyyy').format(date);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  monthName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.8,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  year,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            );
          }),
          Row(
            children: [
              _NavRoundButton(
                icon: Icons.chevron_left,
                onTap: controller.previousMonth,
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: controller.goToToday,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    'Today',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _NavRoundButton(
                icon: Icons.chevron_right,
                onTap: controller.nextMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.onSurface),
      ),
    );
  }
}

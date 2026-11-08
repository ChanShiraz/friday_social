import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/weather.dart';

class DayCellCard extends StatelessWidget {
  final DateTime date;
  final Weather? weather;
  final bool isCurrentMonth;
  final bool isSelected;
  final int eventCount;
  final VoidCallback onTap;

  const DayCellCard({
    super.key,
    required this.date,
    required this.weather,
    this.isCurrentMonth = true,
    required this.isSelected,
    required this.eventCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
    final dayNum = date.day.toString();

    final bgColor = isSelected
        ? AppColors.primaryContainer
        : (!isCurrentMonth
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.4)
            : (isWeekend ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest));

    final textColor = isSelected
        ? AppColors.onPrimary
        : (!isCurrentMonth
            ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
            : (isWeekend ? AppColors.secondary : AppColors.onSurface));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: isCurrentMonth ? 0.3 : 0.15),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayNum,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                ),
                if (eventCount > 0)
                  Container(
                    padding: eventCount > 1
                        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                        : const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary
                          : (eventCount > 2
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: eventCount > 1
                        ? Text(
                            '$eventCount',
                            style: TextStyle(
                              color: isSelected || eventCount > 2
                                  ? Colors.white
                                  : AppColors.secondary,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          )
                        : Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                  )
                else
                  const SizedBox(width: 4, height: 4),
              ],
            ),
            if (weather != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    weather!.iconData,
                    size: 12,
                    color: isSelected
                        ? AppColors.secondaryFixed
                        : (isWeekend ? AppColors.secondary : AppColors.onSurfaceVariant),
                  ),
                  Text(
                    weather!.formattedTemp,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppColors.surfaceContainerHighest
                              : AppColors.onSurfaceVariant,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

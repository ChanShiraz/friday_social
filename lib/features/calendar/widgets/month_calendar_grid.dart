import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../calendar_controller.dart';
import 'day_cell_card.dart';

class MonthCalendarGrid extends StatelessWidget {
  final CalendarController controller;

  const MonthCalendarGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: weekdays.asMap().entries.map((entry) {
              final isWeekend = entry.key >= 5;
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isWeekend
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 2),
          Obx(() {
            final currentMonth = controller.currentMonth.value;
            final days = controller.getCalendarDaysForMonth(currentMonth);
            final selDate = controller.selectedDate.value;
            final _ = controller.selectedRadiusKm.value;
            final _ = controller.eventCountsMap.length;

            if (controller.isLoading.value && controller.days16Forecast.isEmpty) {
              return Container(
                height: 260,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              );
            }

            return GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 0.76,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: days.map((day) {
                final isCurrentMonth = day.month == currentMonth.month;
                final isSelected = day.year == selDate.year &&
                    day.month == selDate.month &&
                    day.day == selDate.day;

                final weather = controller.getWeatherForDate(day);
                final eventCount = controller.getEventCountForDate(day);

                return DayCellCard(
                  date: day,
                  weather: weather,
                  isCurrentMonth: isCurrentMonth,
                  isSelected: isSelected,
                  eventCount: eventCount,
                  onTap: () => controller.selectDate(day),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../calendar_controller.dart';
import '../../location/city_selection_screen.dart';

class AtmosphereHeader extends StatelessWidget {
  final CalendarController controller;

  const AtmosphereHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friday Social',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                  ),
                  Text(
                    'CALENDAR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Obx(
                () => InkWell(
                  onTap: () =>
                      Get.to(() => CitySelectionScreen(controller: controller)),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isLiveGps.value
                              ? Icons.gps_fixed
                              : Icons.near_me,
                          size: 14,
                          color: controller.isLiveGps.value
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          controller.locationDisplayString,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.expand_more,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

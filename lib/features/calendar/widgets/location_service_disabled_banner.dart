import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../calendar_controller.dart';
import '../../location/city_selection_screen.dart';

class LocationServiceDisabledBanner extends StatelessWidget {
  final CalendarController controller;

  const LocationServiceDisabledBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLocationServiceDisabled.value) {
        return const SizedBox.shrink();
      }

      final fallbackCityName = controller.chosenFallbackCity.value.name;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: AppColors.secondary,
              size: 15,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Location off • Using $fallbackCityName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => controller.openLocationSettingsAndRetry(),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Enable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => Get.to(() => CitySelectionScreen(controller: controller)),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'City',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => controller.isLocationServiceDisabled.value = false,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

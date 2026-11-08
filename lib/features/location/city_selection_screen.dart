import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../calendar/calendar_controller.dart';

class CitySelectionScreen extends StatelessWidget {
  final CalendarController controller;

  const CitySelectionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final locations = controller.locationService.getCuratedLocations();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Location & Fallback Hub',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() {
              final isGps = controller.isLiveGps.value;
              final isFallback = controller.isUsingFallback.value;
              final loc = controller.currentLocation.value;
              final fallbackCity = controller.chosenFallbackCity.value;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isGps
                      ? AppColors.surfaceContainer
                      : AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGps
                        ? AppColors.outlineVariant.withValues(alpha: 0.3)
                        : AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isGps
                                ? AppColors.primary
                                : AppColors.secondary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isGps
                                ? Icons.gps_fixed
                                : Icons.location_off_outlined,
                            size: 18,
                            color: isGps ? Colors.white : AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGps
                                    ? 'LIVE USER GPS ACTIVE'
                                    : 'LOCATION PERMISSION DENIED',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: isGps
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                              Text(
                                isGps
                                    ? '${loc.name} (Within ${controller.selectedRadiusKm.value.toInt()} km)'
                                    : 'Fallback: ${fallbackCity.name}, ${fallbackCity.region}',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => controller.retryGpsLocation(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isGps
                                  ? AppColors.surfaceContainerHigh
                                  : AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isGps ? 'Recalibrate' : 'Enable GPS',
                              style: TextStyle(
                                color: isGps
                                    ? AppColors.onSurface
                                    : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isFallback)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Events and weather are loaded within your selected radius from your chosen fallback city.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SELECT OR SET CHOSEN FALLBACK CITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.9,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: locations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final loc = locations[index];

                return Obx(() {
                  final activeLoc = controller.currentLocation.value;
                  final chosenFallback = controller.chosenFallbackCity.value;

                  final isActive = activeLoc.name == loc.name;
                  final isFallbackCity = chosenFallback.name == loc.name;

                  return InkWell(
                    onTap: () {
                      controller.setChosenFallbackCity(loc);
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : (isFallbackCity
                                    ? AppColors.secondary.withValues(alpha: 0.4)
                                    : AppColors.outlineVariant.withValues(
                                        alpha: 0.3,
                                      )),
                          width: isFallbackCity ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 20,
                            color: isActive
                                ? AppColors.secondaryFixed
                                : (isFallbackCity
                                      ? AppColors.secondary
                                      : AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      loc.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.onSurface,
                                          ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.country,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isActive
                                                ? AppColors
                                                      .surfaceContainerHighest
                                                : AppColors.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                    ),
                                    if (isFallbackCity) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.secondary
                                              : AppColors.secondary.withValues(
                                                  alpha: 0.15,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'CHOSEN FALLBACK',
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.secondary,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.atmosphericVibe,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isActive
                                            ? AppColors.outlineVariant
                                            : AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppColors.secondaryFixed,
                            )
                          else
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.outlineVariant,
                            ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
